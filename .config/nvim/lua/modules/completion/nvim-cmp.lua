local M = {}

local vim_config_path = vim.fn.stdpath("config")
local modules_path = vim_config_path .. "/lua/modules"

function M.setup()
	local cmp = require("cmp")

	cmp.setup({
		snippet = {
			expand = function(args)
				-- vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
				require("luasnip").lsp_expand(args.body) -- For `luasnip` users.
				-- vim.fn["UltiSnips#Anon"](args.body) -- For `ultisnips` users.
				-- require'snippy'.expand_snippet(args.body) -- For `snippy` users.
			end,
		},
		mapping = {
			["<c-n>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
			["<c-p>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
			-- @note: Fixes an issue with nvim in an ssh session where pressing <tab> would actually
			--        output the characters "<Tab>". This solution was taken from:
			--        https://www.reddit.com/r/neovim/comments/scnj6i/help_nvimcmp_input_tab_when_pressing_stab_with/
			["<Tab>"] = cmp.mapping(function(_)
				if cmp.visible() then
					cmp.select_next_item()
					return
				end
				vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Tab>", true, true, true), "nt", true)
			end),
			["<S-Tab>"] = cmp.mapping(function(_)
				if cmp.visible() then
					cmp.select_prev_item()
					return
				end
				vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Tab>", true, true, true), "nt", true)
			end),
			["<C-d>"] = cmp.mapping(cmp.mapping.scroll_docs(-4), { "i", "c" }),
			["<C-f>"] = cmp.mapping(cmp.mapping.scroll_docs(4), { "i", "c" }),
			["<C-Space>"] = cmp.mapping(cmp.mapping.complete(), { "i", "c" }),
			["<C-y>"] = cmp.config.disable, -- If you want to remove the default `<C-y>` mapping, You can specify `cmp.config.disable` value.
			["<C-e>"] = cmp.mapping({
				i = cmp.mapping.abort(),
				c = cmp.mapping.close(),
			}),
			["<CR>"] = nil,
			["<C-s>"] = cmp.mapping.confirm({ select = true }),
		},
		sources = cmp.config.sources({
			{ name = "nvim_lsp" },
			{ name = "luasnip" },
			-- { name = 'vsnip' }, -- For vsnip users.
			-- { name = 'ultisnips' }, -- For ultisnips users.
			-- { name = 'snippy' }, -- For snippy users.
			{ name = "path" },
			{ name = "buffer" },
		}),
	})

	-- Use buffer source for `/`.
	cmp.setup.cmdline("/", {
		sources = {
			{ name = "buffer" },
		},
	})

	-- Use cmdline & path source for ':'.
	cmp.setup.cmdline(":", {
		sources = cmp.config.sources({
			{ name = "path" },
			{ name = "cmdline" },
		}),
	})

	cmp.setup.filetype("gitcommit", {
		sources = cmp.config.sources({
			{ name = "handles" },
			{ name = "gitcommit_keywords" },
		}),
	})

	local custom_cmp_source_list = vim.split(vim.fn.globpath(modules_path .. "/completion/sources/", "*.lua"), "\n")

	for _, source in ipairs(custom_cmp_source_list) do
		source = string.match(source, "modules/completion/sources/(.+).lua$")
		require("modules.completion.sources." .. source).setup()
	end
end

return M
