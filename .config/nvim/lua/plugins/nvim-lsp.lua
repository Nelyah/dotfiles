local M = {}

local fn = vim.fn
local utils = require('utils')
local lspconfig = require('lspconfig')
local configs = require('lspconfig/configs')

function M.get_capabilities()
  local capabilities = vim.lsp.protocol.make_client_capabilities()

  -- for nvim-cmp
  capabilities = require("cmp_nvim_lsp").update_capabilities(capabilities)

  -- Code actions
  capabilities.textDocument.codeAction = {
    dynamicRegistration = true,
    codeActionLiteralSupport = {
      codeActionKind = {
        valueSet = (function()
          local res = vim.tbl_values(vim.lsp.protocol.CodeActionKind)
          table.sort(res)
          return res
        end)(),
      },
    },
  }

  capabilities.textDocument.completion.completionItem.snippetSupport = true
  capabilities.textDocument.completion.completionItem.resolveSupport = {
    properties = { "documentation", "detail", "additionalTextEdits" },
  }
  capabilities.experimental = {}
  capabilities.experimental.hoverActions = true

  return capabilities
end

function M.nvim_lsp_installer_setup ()
    local lsp_installer = require("nvim-lsp-installer")
    local lsputils = require('plugins.nvim-lsp')

    -- Register a handler that will be called for each installed server when it's ready (i.e. when installation is finished
    -- or if the server is already installed).
    lsp_installer.on_server_ready(function(server)
        local opts = {}

        if server.name == "sumneko_lua" then
            opts = {
                capabilities = lsputils.get_capabilities(),
                cmd_env = server._default_options.cmd_env,
                settings = {
                    Lua = {
                        runtime = {
                            version = "LuaJIT",
                            path = vim.split(package.path, ";"),
                        },
                        diagnostics = { globals = { "vim" } },
                        workspace = {
                            library = {
                                [vim.fn.expand "$VIMRUNTIME/lua"] = true,
                                [vim.fn.expand "$VIMRUNTIME/lua/vim/lsp"] = true,
                            },
                            maxPreload = 100000,
                            preloadFileSize = 1000,
                        },
                    },
                },
            }
        end

        if server.name == 'clangd' or server.name == 'pylsp'
           or server.name == 'vimls' or server.name == 'zk' then

            opts = {
                capabilities = lsputils.get_capabilities(),
            }
        end

        server:setup(opts)
        -- This setup() function will take the provided server configuration and decorate it with the necessary properties
        -- before passing it onwards to lspconfig.
        -- Refer to https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md
    end)
end

function M.setup ()
    local capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities())

    vim.keymap.set('n', 'gD', '<cmd>lua vim.lsp.buf.definition()<CR>')
    vim.keymap.set('n', 'gh',  '<cmd>lua vim.lsp.buf.hover()<CR>')
    vim.keymap.set('n', 'gi',  '<cmd>lua vim.lsp.buf.implementation()<CR>')
    vim.keymap.set('n', 'gs',  '<cmd>lua vim.lsp.buf.signature_help()<CR>')
    vim.keymap.set('n', '1gD', '<cmd>lua vim.lsp.buf.type_definition()<CR>')
    vim.keymap.set('n', 'gr',  '<cmd>lua vim.lsp.buf.references()<CR>')
    vim.keymap.set('n', 'g0',  '<cmd>lua vim.lsp.buf.document_symbol()<CR>')
    vim.keymap.set('n', 'gW',  '<cmd>lua vim.lsp.buf.workspace_symbol()<CR>')
    vim.keymap.set('n', 'gd',  '<cmd>lua vim.lsp.buf.declaration()<CR>')

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
    vim.cmd[[autocmd! CursorHold * lua vim.diagnostic.open_float({scope = 'line', focusable = false})]]

    vim.g.diagnostic_auto_popup_while_jump = 1
    vim.g.diagnostic_enable_virtual_text = 0
end

return M
