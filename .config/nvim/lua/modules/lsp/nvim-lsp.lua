local M = {}

local on_attach = function(client, bufnr)
	local ls_disable_formatting = { "pylsp", "pyright", "clangd", "tsserver", "gopls" }
	for _, name in ipairs(ls_disable_formatting) do
		if client.name == name then
			client.server_capabilities.documentFormattingProvider = false
			client.server_capabilities.documentRangeFormattingProvider = false
			break
		end
	end
end

function M.lspconfig()
	local capabilities = vim.lsp.protocol.make_client_capabilities()
	local has_cmp_nvim_lsp, cmp_nvim_lsp = pcall(require, "blink.cmp")
	if has_cmp_nvim_lsp then
		capabilities = cmp_nvim_lsp.get_lsp_capabilities(capabilities)
	end

	if vim.fn.executable("nixd") == 1 then
		vim.lsp.config("nixd", {
			cmd = { "nixd" },
			on_attach = on_attach,
			capabilities = capabilities,
			settings = {
				nixd = {
					nixpkgs = {
						expr = "import <nixpkgs> { }",
					},
					formatting = {
						command = { "alejandra" }, -- or nixfmt or nixpkgs-fmt
					},
					-- options = {
					--   nixos = {
					--       expr = '(builtins.getFlake "/PATH/TO/FLAKE").nixosConfigurations.CONFIGNAME.options',
					--   },
					--   home_manager = {
					--       expr = '(builtins.getFlake "/PATH/TO/FLAKE").homeConfigurations.CONFIGNAME.options',
					--   },
					--}
				}
			}
		})
	end


	-- local lsp = require("lspconfig")
	vim.lsp.config("lua_ls", {
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
	vim.lsp.config("pylsp", {
		on_attach = on_attach,
		capabilities = capabilities,
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

	-- https://neovim.io/doc/user/diagnostic.html
	vim.api.nvim_create_autocmd("LspAttach", {
		group = vim.api.nvim_create_augroup("lsp-attach", { clear = true }),
		callback = function(args)
			local bufnr = args.buf
			vim.keymap.set("n", "gD", vim.lsp.buf.definition, { buffer = bufnr })
			vim.keymap.set("n", "gh", vim.lsp.buf.hover, { buffer = bufnr })
			vim.keymap.set("n", "gi", vim.lsp.buf.implementation, { buffer = bufnr })
			vim.keymap.set("n", "1gD", vim.lsp.buf.type_definition, { buffer = bufnr })
			vim.keymap.set("n", "gr", vim.lsp.buf.references, { buffer = bufnr })
			vim.keymap.set("n", "gR", vim.lsp.buf.rename, { buffer = bufnr })
			vim.keymap.set({ "n", "v" }, "ga", vim.lsp.buf.code_action, { buffer = bufnr })
			vim.keymap.set("n", "g0", vim.lsp.buf.document_symbol, { buffer = bufnr })
			vim.keymap.set("n", "gW", vim.lsp.buf.workspace_symbol, { buffer = bufnr })
			vim.keymap.set("n", "gd", vim.lsp.buf.declaration, { buffer = bufnr })
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

	-- Check for event after that many ms
	vim.opt.updatetime = 700

	local diagnositics_virtual_text_config = {
		prefix = "●",
	}
	vim.diagnostic.config({
		severity_sort = true,
		virtual_text = diagnositics_virtual_text_config,
		underline = false,
		update_in_insert = false,
		float = { border = border },
	})

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
				virtual_text = not has_diagnostic_on_current_line() and diagnositics_virtual_text_config or false,
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
					virtual_lines = false,
				})
			end
		end,
	})
end

function M.enable()
	local to_enable = {}

	local has_mason_lspconfig, mason_lspconfig = pcall(require, "mason-lspconfig")
	if has_mason_lspconfig then
		local installed = mason_lspconfig.get_installed_servers()
		if type(installed) == "table" then
			vim.list_extend(to_enable, installed)
		end
	end

	-- Always try these, even if they're not installed via Mason.
	vim.list_extend(to_enable, { "lua_ls", "pylsp", "nixd" })

	local seen = {}
	local unique = {}
	for _, name in ipairs(to_enable) do
		if type(name) == "string" and name ~= "" and not seen[name] then
			seen[name] = true
			table.insert(unique, name)
		end
	end

	if #unique > 0 then
		vim.lsp.enable(unique)
	end
end

return M
