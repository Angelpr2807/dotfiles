return {
    {
        "stevearc/conform.nvim",
        -- event = 'BufWritePre', -- uncomment for format on save
        config = function()
            require "configs.conform"
        end,
    },

    -- These are some examples, uncomment them if you want to see them work!
    {
        "neovim/nvim-lspconfig",
        config = function()
            require("nvchad.configs.lspconfig").defaults()
            require "configs.lspconfig"
        end,
    },
    {
        "nvim-tree/nvim-tree.lua",
        version = "*",
        lazy = false,
        dependencies = {
            "nvim-tree/nvim-web-devicons",
        },
        config = require("configs.nvim-tree")
    },
    {
        "williamboman/mason.nvim",
        opts = {
            ensure_installed = {
                "alex",
                "astro-language-server",
                "autoflake",
                "autopep8",
                "bash-debug-adapter",
                "bash-language-server",
                "beautysh",
                "cbfmt",
                "cfn-lint",
                "chrome-debug-adapter",
                "clangd",
                "cpptools",
                "css-variables-language-server",
                "debugpy",
                "docker-compose-language-service",
                "dockerfile-language-server",
                "emmet-language-server",
                "emmet-ls",
                "eslint_d",
                "golangci-lint",
                "grammarly-languageserver",
                "html-lsp",
                "intelephense",
                "julia-lsp",
                "lua-language-server",
                "node-debug2-adapter",
                "php-debug-adapter",
                "phpcs",
                "prettierd",
                "pylint",
                "python-lsp-server",
                "rust-analyzer",
                "snyk",
                "typescript-language-server",
            },
        },
    },
    --
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        event = "VeryLazy",
        main = "nvim-treesitter.configs",
        opts = {
            ensure_installed = {
                "lua",
                "luadoc",
                "astro",
                "bash",
                "c",
                "cpp",
                "css",
                "disassembly",
                "go",
                "html",
                "http",
                "java",
                "javascript",
                "json",
                "json5",
                "julia",
                "perl",
                "php",
                "python",
                "ruby",
                "rust",
                "scss",
                "slint",
                "sql",
                "ssh_config",
                "toml",
                "tsx",
                "typescript",
                "vim",
                "xml",
                "yaml"
            },
            highlight = {
                enable = true,
            },
            indend = {
                enable = true,
            },
        },
    },
}
