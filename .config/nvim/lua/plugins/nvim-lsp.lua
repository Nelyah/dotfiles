local M = {}

local fn = vim.fn
local utils = require('utils')
local lspconfig = require('lspconfig')
local configs = require('lspconfig/configs')

function M.setup ()
    local capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities())
    if (fn.executable('clangd') == 1) then
        lspconfig.clangd.setup{ capabilities = capabilities }
    end
    if (fn.executable('pylsp') == 1) then
        lspconfig.pylsp.setup{ capabilities = capabilities }
    end
    if (fn.executable('bash-language-server') == 1) then
        lspconfig.bashls.setup{ capabilities = capabilities }
    end
    if (fn.executable('vim-language-server') == 1) then
        lspconfig.vimls.setup{ capabilities = capabilities}
    end

    if (fn.executable('zk') == 1) then
        configs.zk = {
          default_config = {
            cmd = {'zk', 'lsp'},
            filetypes = {'markdown'},
            root_dir = function()
              return vim.loop.cwd()
            end,
            settings = {}
          };
        }

        lspconfig.zk.setup({ capabilities = capabilities })
    end


    local cmd = nil

    if fn.has('unix') == 1 then
      cmd = '/usr/bin/lua-language-server'
      if fn.executable(cmd) == 1 then
        cmd = {cmd}
      else
        cmd = nil
      end
    else
      cmd = 'lua-language-server'
      if fn.executable(cmd) == 1 then
        cmd = {cmd}
      else
        cmd = nil
      end
    end

    if cmd ~= nil then
      require'lspconfig'.sumneko_lua.setup{
        cmd = cmd,
        capabilities = capabilities,
        settings = {
          Lua = {
            diagnostics = {
              enable = true,
              globals = {'vim'},
            },
            filetypes = {'lua'},
            runtime = {
              path = vim.split(package.path, ';'),
              version = 'LuaJIT',
            },
          }
        },
      }
    end

    utils.nnoremap('2gD', '<cmd>lua vim.lsp.buf.definition()<CR>')
    utils.nnoremap('gh',  '<cmd>lua vim.lsp.buf.hover()<CR>')
    utils.nnoremap('gi',  '<cmd>lua vim.lsp.buf.implementation()<CR>')
    utils.nnoremap('gs',  '<cmd>lua vim.lsp.buf.signature_help()<CR>')
    utils.nnoremap('1gD', '<cmd>lua vim.lsp.buf.type_definition()<CR>')
    utils.nnoremap('gr',  '<cmd>lua vim.lsp.buf.references()<CR>')
    utils.nnoremap('g0',  '<cmd>lua vim.lsp.buf.document_symbol()<CR>')
    utils.nnoremap('gW',  '<cmd>lua vim.lsp.buf.workspace_symbol()<CR>')
    utils.nnoremap('gd',  '<cmd>lua vim.lsp.buf.declaration()<CR>')

    vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
      vim.lsp.diagnostic.on_publish_diagnostics, {
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
      }
    )

    -- Check for event after that much ms
    vim.opt.updatetime = 700

    -- Event listener for when we're holding the cursor. This event is called
    -- for every 700ms (value of updatetime). If it's true, then show the
    -- diagnostics in a popup window
    vim.cmd[[autocmd! CursorHold * lua vim.lsp.diagnostic.show_line_diagnostics({focusable = false})]]

    vim.g.diagnostic_auto_popup_while_jump = 1
    vim.g.diagnostic_enable_virtual_text = 0
end

return M
