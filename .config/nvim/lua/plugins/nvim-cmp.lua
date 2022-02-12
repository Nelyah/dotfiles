local M = {}

function M.setup ()
    -- vim.g.cpp_simple_highlight = 1

    vim.cmd[[hi default LspCxxHlGroupNamespace ctermfg=Yellow guifg=#E5C07B cterm=none gui=none]]
    vim.cmd[[hi default LspCxxHlGroupMemberVariable ctermfg=White guifg=#F16E77]]

    -- Completion menu
    -- vim.opt.completeopt = {'menuone', 'noselect' }

    -- require'compe'.setup({
    --   enabled = true,
    --   autocomplete = true,
    --   debug = false,
    --   min_length = 1,
    --   preselect = 'enable',
    --   throttle_time = 80,
    --   source_timeout = 200,
    --   incomplete_delay = 400,
    --   max_abbr_width = 100,
    --   max_kind_width = 100,
    --   max_menu_width = 100,
    --   documentation = true,

    --   source = {
    --     path = true,
    --     buffer = false,
    --     calc = true,
    --     emoji = true,
    --     nvim_lsp = true,
    --     nvim_lua = true,
    --     vsnip = true,
    --     ultisnips = true,
    --   };
    -- })
    -- Setup nvim-cmp.
  local cmp = require'cmp'

  cmp.setup({
    snippet = {
      expand = function(args)
        -- vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
        -- require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
        vim.fn["UltiSnips#Anon"](args.body) -- For `ultisnips` users.
        -- require'snippy'.expand_snippet(args.body) -- For `snippy` users.
      end,
    },
    mapping = {
      ['<Tab>'] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
      ['<S-Tab>'] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
      ['<C-d>'] = cmp.mapping(cmp.mapping.scroll_docs(-4), { 'i', 'c' }),
      ['<C-f>'] = cmp.mapping(cmp.mapping.scroll_docs(4), { 'i', 'c' }),
      ['<C-Space>'] = cmp.mapping(cmp.mapping.complete(), { 'i', 'c' }),
      ['<C-y>'] = cmp.config.disable, -- If you want to remove the default `<C-y>` mapping, You can specify `cmp.config.disable` value.
      ['<C-e>'] = cmp.mapping({
        i = cmp.mapping.abort(),
        c = cmp.mapping.close(),
      }),
      ['<CR>'] = nil,
      ['<C-c>'] = cmp.mapping.confirm({ select = true }),
    },
    sources = cmp.config.sources({
      { name = 'nvim_lsp' },
      -- { name = 'vsnip' }, -- For vsnip users.
      -- { name = 'luasnip' }, -- For luasnip users.
      { name = 'ultisnips' }, -- For ultisnips users.
      -- { name = 'snippy' }, -- For snippy users.
      { name = 'path' },
    }, {
      { name = 'buffer' },
    })
  })

  -- Use buffer source for `/`.
  cmp.setup.cmdline('/', {
    sources = {
      { name = 'buffer' },
    }
  })

  -- Use cmdline & path source for ':'.
  cmp.setup.cmdline(':', {
    sources = cmp.config.sources({
      { name = 'path' }
    }, {
      { name = 'cmdline' }
    })
  })

end

return M
