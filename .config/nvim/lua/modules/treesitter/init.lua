local registry = require("modules.treesitter.registry")

local M = {}

local uv = vim.uv or vim.loop
local data_dir = vim.fn.stdpath("data")
local site_dir = vim.fs.joinpath(data_dir, "site")
local parser_dir = vim.fs.joinpath(site_dir, "parser")
local query_root = vim.fs.joinpath(site_dir, "queries")
local source_root = vim.fs.joinpath(data_dir, "treesitter-sources")
local platform = nil
local queue = {}
local queued = {}
local running = false
local notified = {}
local skipped_filetypes = {
	fidget = true,
}

local function notify(message, level, opts)
	opts = opts or {}
	if opts.silent then
		return
	end
	vim.notify(message, level or vim.log.levels.INFO)
end

local function notify_once(key, message, level, opts)
	opts = opts or {}
	if opts.silent then
		return
	end
	if notified[key] then
		return
	end
	notified[key] = true
	vim.notify(message, level or vim.log.levels.INFO)
end

local function mkdir(path)
	vim.fn.mkdir(path, "p")
end

local function is_dir(path)
	local stat = uv.fs_stat(path)
	return stat and stat.type == "directory"
end

local function parser_path(lang)
	return vim.fs.joinpath(parser_dir, lang .. ".so")
end

local function parser_on_runtimepath(lang)
	return #vim.api.nvim_get_runtime_file("parser/" .. lang .. ".*", false) > 0
end

local function command_output(result)
	local stdout = result.stdout or ""
	local stderr = result.stderr or ""
	local output = vim.trim(stdout .. "\n" .. stderr)
	if output == "" then
		return "exit code " .. tostring(result.code)
	end
	return output
end

local function run(command, opts, callback)
	opts = opts or {}
	local ok, err = pcall(function()
		vim.system(command, vim.tbl_extend("force", { text = true }, opts), function(result)
			vim.schedule(function()
				callback(result.code == 0, command_output(result), result)
			end)
		end)
	end)
	if not ok then
		vim.schedule(function()
			callback(false, tostring(err), nil)
		end)
	end
end

local function platform_key()
	if platform then
		return platform
	end

	local uname = uv.os_uname()
	local system = uname.sysname
	local machine = uname.machine

	if system == "Darwin" then
		system = "macos"
	elseif system == "Linux" then
		system = "linux"
	elseif system == "Windows_NT" then
		system = "windows"
	else
		system = string.lower(system)
	end

	if machine == "arm64" then
		machine = "arm64"
	elseif machine == "aarch64" then
		machine = "arm64"
	elseif machine == "x86_64" then
		machine = "x64"
	elseif machine == "amd64" then
		machine = "x64"
	else
		machine = string.lower(machine)
	end

	platform = system .. "-" .. machine
	return platform
end

local function binary_for(parser)
	if not parser.binary then
		return nil
	end
	return parser.binary[platform_key()]
end

local function source_key(parser)
	local name = parser.repo:gsub("%.git$", ""):match("([^/]+)$") or "grammar"
	local revision = parser.revision or "head"
	revision = revision:gsub("[^%w]", ""):sub(1, 16)
	return name .. "-" .. revision
end

local function source_dir(parser)
	return vim.fs.joinpath(source_root, source_key(parser))
end

local function build_dir(parser)
	local root = source_dir(parser)
	if parser.location then
		return vim.fs.joinpath(root, parser.location)
	end
	return root
end

local function parser_available(lang)
	local ok, loaded = pcall(vim.treesitter.language.add, lang)
	return ok and loaded == true
end

local function resolve_lang(name)
	if vim.treesitter.language and vim.treesitter.language.get_lang then
		return vim.treesitter.language.get_lang(name) or name
	end
	return name
end

local function should_skip_buffer(buf)
	local ft = vim.bo[buf].filetype
	if skipped_filetypes[ft] then
		return true
	end
	if vim.bo[buf].buftype ~= "" then
		return true
	end
	return false
end

local function copy_queries(lang, from_dir)
	local source = vim.fs.joinpath(from_dir, "queries")
	if not is_dir(source) then
		return
	end

	local target = vim.fs.joinpath(query_root, lang)
	mkdir(target)

	local handle = uv.fs_scandir(source)
	if not handle then
		return
	end

	while true do
		local name, filetype = uv.fs_scandir_next(handle)
		if not name then
			break
		end
		if filetype == "file" and name:match("%.scm$") then
			local lines = vim.fn.readfile(vim.fs.joinpath(source, name))
			vim.fn.writefile(lines, vim.fs.joinpath(target, name))
		end
	end
end

local function checkout_source(parser, callback)
	local dir = source_dir(parser)
	if not parser.revision then
		callback(true, "")
		return
	end

	run({ "git", "-C", dir, "rev-parse", "--verify", parser.revision }, {}, function(exists)
		local function checkout()
			run({ "git", "-C", dir, "checkout", "--detach", parser.revision }, {}, callback)
		end

		if exists then
			checkout()
			return
		end

		run({ "git", "-C", dir, "fetch", "--filter=blob:none", "--tags", "origin" }, {}, function(ok, output)
			if not ok then
				callback(false, output)
				return
			end
			checkout()
		end)
	end)
end

local function ensure_source(parser, callback)
	local dir = source_dir(parser)
	if is_dir(dir) then
		checkout_source(parser, callback)
		return
	end

	mkdir(source_root)
	run({ "git", "clone", "--filter=blob:none", parser.repo, dir }, {}, function(ok, output)
		if not ok then
			callback(false, output)
			return
		end
		checkout_source(parser, callback)
	end)
end

local function run_build(lang, parser, callback)
	local dir = build_dir(parser)
	local out = parser_path(lang)

	local function build()
		run({ "tree-sitter", "build", "--output", out, dir }, {}, function(ok, output)
			if ok then
				copy_queries(lang, dir)
			end
			callback(ok, output)
		end)
	end

	if parser.generate then
		run({ "tree-sitter", "generate" }, { cwd = dir }, function(ok, output)
			if not ok then
				callback(false, output)
				return
			end
			build()
		end)
		return
	end

	build()
end

local function verify_sha256(path, expected, callback)
	local command = nil
	if vim.fn.executable("sha256sum") == 1 then
		command = { "sha256sum", path }
	elseif vim.fn.executable("shasum") == 1 then
		command = { "shasum", "-a", "256", path }
	else
		callback(false, "no sha256 tool available")
		return
	end

	run(command, {}, function(ok, output)
		if not ok then
			callback(false, output)
			return
		end

		local actual = output:match("^(%w+)")
		callback(actual == expected, output)
	end)
end

local function install_binary(lang, binary, callback)
	if vim.fn.executable("curl") ~= 1 then
		callback(false, "curl is not installed")
		return
	end

	if not binary.sha256 then
		callback(false, "binary is missing sha256")
		return
	end

	local tmp = parser_path(lang) .. ".tmp"
	run({ "curl", "-fL", "-o", tmp, binary.url }, {}, function(ok, output)
		if not ok then
			callback(false, output)
			return
		end

		verify_sha256(tmp, binary.sha256, function(valid, verify_output)
			if not valid then
				pcall(uv.fs_unlink, tmp)
				callback(false, "sha256 mismatch: " .. verify_output)
				return
			end

			local renamed, rename_error = uv.fs_rename(tmp, parser_path(lang))
			if not renamed then
				callback(false, tostring(rename_error))
				return
			end
			callback(true, "")
		end)
	end)
end

local function install_source(lang, parser, callback)
	if vim.fn.executable("tree-sitter") ~= 1 then
		callback(false, "tree-sitter CLI is not installed")
		return
	end

	ensure_source(parser, function(ok, output)
		if not ok then
			callback(false, output)
			return
		end
		run_build(lang, parser, callback)
	end)
end

local function finish_install(item, ok, output)
	local lang = item.lang
	local waiters = queued[lang] or {}
	queued[lang] = nil

	if ok and not parser_available(lang) then
		ok = false
		output = "parser was built but Neovim could not load it"
	end

	if ok then
		notify("Installed Tree-sitter parser: " .. lang, vim.log.levels.INFO, item.opts)
	else
		notify_once(
			"install-failed:" .. lang,
			"Tree-sitter install failed for " .. lang .. ": " .. output,
			vim.log.levels.WARN,
			item.opts
		)
	end

	for _, waiter in ipairs(waiters) do
		waiter(ok)
	end

	if item.done then
		item.done()
	end
end

local function install_item(item)
	local lang = item.lang
	local parser = registry.parsers[lang]
	local binary = parser and binary_for(parser) or nil

	if parser_available(lang) then
		finish_install(item, true, "")
		return
	end

	if not parser then
		finish_install(item, false, "no registry entry")
		return
	end

	mkdir(parser_dir)

	if binary then
		install_binary(lang, binary, function(ok, output)
			if ok then
				finish_install(item, true, output)
				return
			end

			install_source(lang, parser, function(source_ok, source_output)
				finish_install(item, source_ok, source_ok and source_output or output .. "\n" .. source_output)
			end)
		end)
		return
	end

	install_source(lang, parser, function(ok, output)
		finish_install(item, ok, output)
	end)
end

local function process_queue()
	if running then
		return
	end

	local item = table.remove(queue, 1)
	if not item then
		return
	end

	running = true
	install_item(vim.tbl_extend("force", item, {
		done = function()
			running = false
			process_queue()
		end,
	}))
end

local function enqueue(lang, opts, callback)
	opts = opts or {}
	callback = callback or function() end

	lang = resolve_lang(lang)
	if parser_available(lang) then
		callback(true)
		return
	end

	if queued[lang] then
		table.insert(queued[lang], callback)
		if opts.priority then
			for index, item in ipairs(queue) do
				if item.lang == lang then
					table.remove(queue, index)
					table.insert(queue, 1, item)
					break
				end
			end
		end
		return
	end

	queued[lang] = { callback }
	local item = { lang = lang, opts = opts }
	if opts.priority then
		table.insert(queue, 1, item)
	else
		table.insert(queue, item)
	end
	process_queue()
end

function M.install(lang, opts, callback)
	enqueue(lang, opts, callback)
end

function M.install_ensured(opts, callback)
	opts = opts or {}
	local missing = 0
	local seen = {}
	local index = 1
	local batch_size = opts.batch_size or 8

	local function finish()
		if missing == 0 then
			notify("Tree-sitter parsers already installed.", vim.log.levels.INFO, opts)
		else
			notify("Installing " .. missing .. " Tree-sitter parser(s).", vim.log.levels.INFO, opts)
		end

		if callback then
			callback(missing)
		end
	end

	local function step()
		local stop = math.min(index + batch_size - 1, #registry.ensure_installed)
		while index <= stop do
			local resolved = resolve_lang(registry.ensure_installed[index])
			if not seen[resolved] and not parser_on_runtimepath(resolved) and registry.parsers[resolved] then
				seen[resolved] = true
				missing = missing + 1
				enqueue(resolved, opts)
			end
			index = index + 1
		end

		if index <= #registry.ensure_installed then
			vim.schedule(step)
			return
		end

		finish()
	end

	vim.schedule(step)
end

function M.status_lines()
	local lines = { "Tree-sitter parsers (" .. platform_key() .. ")" }
	local has_cli = vim.fn.executable("tree-sitter") == 1

	for _, lang in ipairs(registry.ensure_installed) do
		local resolved = resolve_lang(lang)
		local parser = registry.parsers[resolved]
		local status = nil

		if parser_on_runtimepath(resolved) then
			status = "installed"
		elseif parser and binary_for(parser) then
			status = "binary available"
		elseif parser and has_cli then
			status = "source build available"
		elseif parser then
			status = "missing tree-sitter CLI"
		else
			status = "unavailable"
		end

		if resolved ~= lang then
			table.insert(lines, lang .. " -> " .. resolved .. ": " .. status)
		else
			table.insert(lines, lang .. ": " .. status)
		end
	end

	return lines
end

local function show_status()
	local lines = M.status_lines()
	vim.cmd("new")
	local buf = vim.api.nvim_get_current_buf()
	vim.bo[buf].buftype = "nofile"
	vim.bo[buf].bufhidden = "wipe"
	vim.bo[buf].swapfile = false
	vim.api.nvim_buf_set_name(buf, "Tree-sitter parser status")
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
	vim.bo[buf].modifiable = false
end

local function start_buffer(buf, lang)
	if not vim.api.nvim_buf_is_loaded(buf) or not parser_available(lang) then
		return
	end
	pcall(vim.treesitter.start, buf, lang)
end

local function setup_commands()
	vim.api.nvim_create_user_command("TSInstall", function(args)
		for _, lang in ipairs(args.fargs) do
			M.install(lang, { priority = true }, function(ok)
				if ok then
					notify("Tree-sitter parser ready: " .. resolve_lang(lang))
				end
			end)
		end
	end, {
		nargs = "+",
		complete = function()
			return vim.tbl_keys(registry.parsers)
		end,
	})

	vim.api.nvim_create_user_command("TSInstallEnsured", function()
		M.install_ensured()
	end, {})

	vim.api.nvim_create_user_command("TSParserStatus", show_status, {})
end

local function setup_autocmd()
	local group = vim.api.nvim_create_augroup("native-treesitter", { clear = true })
	vim.api.nvim_create_autocmd("FileType", {
		group = group,
		callback = function(args)
			if should_skip_buffer(args.buf) then
				return
			end

			local ft = vim.bo[args.buf].filetype
			if ft == "" then
				return
			end

			local lang = resolve_lang(ft)
			if parser_available(lang) then
				start_buffer(args.buf, lang)
				return
			end

			if not registry.parsers[lang] then
				notify_once(
					"missing-registry:" .. lang,
					"No Tree-sitter parser registry entry for " .. lang,
					vim.log.levels.INFO
				)
				return
			end

			M.install(lang, { priority = true }, function(ok)
				if ok then
					start_buffer(args.buf, lang)
				end
			end)
		end,
	})
end

local function register_aliases()
	for lang, filetypes in pairs(registry.aliases) do
		pcall(vim.treesitter.language.register, lang, filetypes)
	end
end

function M.setup()
	mkdir(parser_dir)
	mkdir(query_root)
	vim.opt.runtimepath:prepend(site_dir)
	register_aliases()
	setup_commands()
	setup_autocmd()
	vim.defer_fn(function()
		M.install_ensured({ silent = true })
	end, 1000)
end

M.setup()

return M
