require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set
local builtin = require('telescope.builtin')

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")

-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")
map('n', '<leader>n', '<cmd>enew<CR>', {noremap = true, silent = true, desc = "New empty buffer"})

-- nvim tree
map("n", "<leader>e", "<cmd> NvimTreeToggle <CR>", {desc = "Focus nvimTree"})

-- telescope
map('n', '<leader>sf', builtin.find_files, {desc = "show files"})
map('n', '<leader>sh', builtin.command_history, {desc = "show command history"})
map('n', '<leader>ob', builtin.buffers, {desc = "show buffers"})
map('n', '<leader>gc', builtin.git_commits, {desc = "show git commits"})
map('n', '<leader>gs', builtin.git_status, {desc = "show git status"})
