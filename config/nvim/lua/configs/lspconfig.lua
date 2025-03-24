-- EXAMPLE 
local on_attach = require("nvchad.configs.lspconfig").on_attach
local on_init = require("nvchad.configs.lspconfig").on_init
local capabilities = require("nvchad.configs.lspconfig").capabilities

local lspconfig = require "lspconfig"
local servers = { "html", "cssls", "emmet_ls", "rust_analyzer", "bashls", "clangd" }

-- lsps with default config
for _, lsp in ipairs(servers) do
  lspconfig[lsp].setup {
    on_attach = on_attach,
    on_init = on_init,
    capabilities = capabilities,
  }
end

lspconfig.ts_ls.setup {}
lspconfig.astro.setup{}
lspconfig.lua_ls.setup{}
lspconfig.emmet_ls.setup{}
lspconfig.bashls.setup{}
lspconfig.clangd.setup{}
lspconfig.css_variables.setup{}
lspconfig.html.setup{}
lspconfig.docker_compose_language_service.setup{}
lspconfig.dockerls.setup{}
lspconfig.intelephense.setup{}
lspconfig.julials.setup{}
lspconfig.rust_analyzer.setup{}
lspconfig.pylsp.setup{}
lspconfig.grammarly.setup{}
