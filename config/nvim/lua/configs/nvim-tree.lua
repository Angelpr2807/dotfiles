-- Function to set highlight groups
local function set_highlights()
    vim.api.nvim_set_hl(0, "NvimTreeIndentMarker", {
        fg = "#d3d3d3"
    })
    vim.api.nvim_set_hl(0, "NvimTreeStatusLine", {
        bg = "#1e222a"
    })
    -- Set statusline background color
    vim.api.nvim_set_hl(0, "NvimTreeEndOfBuffer", {
        fg = "#1e222a"
    }) -- Set end of buffer color to match background

    -- Highlight selected file or folder
    vim.api.nvim_set_hl(0, "NvimTreeCursorLine", {
        bg = "#383D4E"
    }) -- Set background color when a file or folder is selected
    vim.api.nvim_set_hl(0, "NvimTreeCursorLineNr", {
        fg = "#abb2bf",
        bg = "#383D4E"
    }) -- Set foreground and background color of line number when a file or folder is selected
end


local config = function()
    dofile(vim.g.base46_cache .. "nvimtree")

    local nvtree = require "nvim-tree"
    local api = require "nvim-tree.api"

    -- Set custom highlights
    set_highlights()

    -- Automatically open file upon creation
    api.events.subscribe(api.events.Event.FileCreated, function(file)
        vim.cmd("edit " .. file.fname)
    end)

    nvtree.setup {
        on_attach = custom_on_attach,
        sync_root_with_cwd = true,
        -- hijack_unnamed_buffer_when_opening = false,
        update_focused_file = {
            enable = true,
            update_cwd = true,
            ignore_list = {}
        },
        git = {
            enable = true
        },
        renderer = {
            indent_markers = {
                enable = true,
                icons = {
                    corner = "└",
                    edge = "│",
                    item = "├",
                    none = " "
                }
            },
            highlight_git = "none",
            icons = {
                glyphs = {
                    folder = {
                        default = "",
                        open = "",
                        empty = "",
                        empty_open = ""
                    },
                    git = {
                        unstaged = "",
                        staged = "",
                        unmerged = "",
                        renamed = "",
                        untracked = "",
                        deleted = "",
                        ignored = "󰴲"
                    }
                }
            }
        },
        view = {
            width = 30,
            side = "left",
            signcolumn = "no"
        },
        filesystem_watchers = {
            ignore_dirs = {"node_modules"}
        }
    }
end

return config
