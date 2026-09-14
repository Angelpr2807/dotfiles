-- EXAMPLE 
require("nvchad.configs.lspconfig").defaults()

local lspenable = vim.lsp.enable
local servers = { "html",
    "cssls",
    "emmet_ls",
    "rust_analyzer",
    "bashls",
    "clangd",
    "ts_ls",
    "astro",
    "lua_ls",
    "emmet_ls",
    "bashls",
    "clangd",
    "css_variables",
    "html",
    "docker_compose_language_service",
    "dockerls",
    "intelephense",
    "julials",
    "rust_analyzer",
    "pylsp",
    "grammarly",
}

lspenable(servers)
