local M = {}

local on_attach = function(client, bufnr)
	local ls_disable_formatting = { "pylsp", "pyright", "clangd", "tsserver", "gopls" }
	local keymap_ignore_ls_formats = ""
	local first = true
	for _, name in ipairs(ls_disable_formatting) do
		if client.name == name then
			client.server_capabilities.document_formatting = false
		end
		if not first then
			keymap_ignore_ls_formats = keymap_ignore_ls_formats .. "and "
		end
		first = false
		keymap_ignore_ls_formats = keymap_ignore_ls_formats .. 'client.name ~= "' .. name .. '" '
	end

	-- https://neovim.io/doc/user/diagnostic.html
	vim.diagnostic.config({
		underline = false,
	})

	vim.keymap.set("n", "gD", "<cmd>lua vim.lsp.buf.definition()<CR>")
	vim.keymap.set("n", "gh", "<cmd>lua vim.lsp.buf.hover()<CR>")
	vim.keymap.set("n", "gi", "<cmd>lua vim.lsp.buf.implementation()<CR>")
	vim.keymap.set("n", "1gD", "<cmd>lua vim.lsp.buf.type_definition()<CR>")
	vim.keymap.set("n", "gr", "<cmd>lua vim.lsp.buf.references()<CR>")
	vim.keymap.set("n", "gR", "<cmd>lua vim.lsp.buf.rename()<CR>")
	vim.keymap.set({ "n", "v" }, "ga", vim.lsp.buf.code_action)
	vim.keymap.set("n", "g0", "<cmd>lua vim.lsp.buf.document_symbol()<CR>")
	vim.keymap.set("n", "gW", "<cmd>lua vim.lsp.buf.workspace_symbol()<CR>")
	vim.keymap.set("n", "gd", "<cmd>lua vim.lsp.buf.declaration()<CR>")
end

function M.mason_lspconfig()
	local capabilities = vim.lsp.protocol.make_client_capabilities()
	local has_cmp_nvim_lsp, cmp_nvim_lsp = pcall(require, "blink.cmp")
	if has_cmp_nvim_lsp then
		capabilities = cmp_nvim_lsp.get_lsp_capabilities(capabilities)
	end

	local function file_exists(name)
		local f = io.open(name, "r")
		if f ~= nil then
			io.close(f)
			return true
		else
			return false
		end
	end

	require("mason-lspconfig").setup_handlers({
		-- The first entry (without a key) will be the default handler
		-- and will be called for each installed server that doesn't have
		-- a dedicated handler.
		function(server_name) -- default handler (optional)
			local lsp = require("lspconfig")
			if server_name == "lua_ls" then
				lsp[server_name].setup({
					on_attach = on_attach,
					capabilities = capabilities,
					settings = {
						Lua = {
							hint = {
								enable = true,
							},
							runtime = {
								version = "LuaJIT",
								path = vim.split(package.path, ";"),
							},
							diagnostics = { globals = { "vim" } },
							workspace = {
								library = {
									vim.api.nvim_get_runtime_file("", true),
									"${3rd}/luv/library",
								},
								checkThirdParty = false,
								maxPreload = 100000,
								preloadFileSize = 1000,
							},
							telemetry = {
								enable = false,
							},
						},
					},
				})
			elseif server_name == "pylsp" then
				lsp[server_name].setup({
					on_attach = on_attach,
					settings = {
						pylsp = {
							-- Those linters are already handled by ruff
							configurationSources = {},
							plugins = {
								pycodestyle = { enabled = false },
								pydocstyle = { enabled = false },
								pylint = { enabled = false },
								flake8 = { enabled = false },
								yapf = { enabled = false },
								isort = { enabled = false },
							},
						},
					},
				})
			else
				lsp[server_name].setup({
					on_attach = on_attach,
					capabilities = capabilities,
				})
			end
		end,
	})
end

function M.setup()
	-- UI tweaks from https://github.com/neovim/nvim-lspconfig/wiki/UI-customization
	local border = {
		{ "╭", "FloatBorder" },
		{ "─", "FloatBorder" },
		{ "╮", "FloatBorder" },
		{ "│", "FloatBorder" },
		{ "╯", "FloatBorder" },
		{ "─", "FloatBorder" },
		{ "╰", "FloatBorder" },
		{ "│", "FloatBorder" },
	}

	vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = border })
	vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, { border = border })
	vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {
		-- This will disable virtual text, like doing:
		-- let g:diagnostic_enable_virtual_text = 0
		virtual_text = false,
		-- This is similar to:
		-- let g:diagnostic_show_sign = 1
		-- To configure sign display,
		--  see: ":help vim.lsp.diagnostic.set_signs()"
		signs = true,
		-- This is similar to:
		-- "let g:diagnostic_insert_delay = 1"
		update_in_insert = false,
	})

	-- Check for event after that many ms
	vim.opt.updatetime = 700

	local diagnositics_virtual_text_config = {
		prefix = "●",
	}
	vim.diagnostic.config {
		severity_sort = true,
		virtual_text = diagnositics_virtual_text_config,
	}

	-- Event listener for when we're holding the cursor. This event is called
	-- for every 700ms (value of updatetime). If it's true, then show the
	-- diagnostics in a popup window
	--
	-- This: 
	-- When NOT on Diagnostic
	-- 		Shows virtual text
	-- 		Disables the virtual_lines
	--	When ON a diagnostic
	--		Activates after a timeout (700ms)
	--			Disables virtual text
	--			Enables virtual_lines
	local function has_diagnostic_on_current_line()
		local current_line = vim.api.nvim_win_get_cursor(0)[1] - 1 -- Get current line (0-based index)
		local diagnostics = vim.diagnostic.get(0, { lnum = current_line })
		return #diagnostics > 0
	end
	local diagnostic_hover_group = vim.api.nvim_create_augroup("diagnostic-hover", { clear = true })

	vim.api.nvim_create_autocmd("CursorHold", {
		group = diagnostic_hover_group,
		pattern = "*",
		callback = function()
			vim.diagnostic.config({
				virtual_lines = has_diagnostic_on_current_line() and { current_line = true } or false,
				virtual_text = not has_diagnostic_on_current_line() and
					diagnositics_virtual_text_config or false
			})
		end,
	})
	vim.api.nvim_create_autocmd("CursorMoved", {
		group = diagnostic_hover_group,
		pattern = "*",
		callback = function()
			if not has_diagnostic_on_current_line() then
				vim.diagnostic.config({
					virtual_text = diagnositics_virtual_text_config,
					virtual_lines = false
				})
			end
		end,
	})
end

return M
