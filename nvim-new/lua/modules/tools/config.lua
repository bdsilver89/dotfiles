local config = {}

function config.telescope()
    vim.cmd([[packadd telescope-file-browser.nvim]])

    local actions = require("telescope.actions")
    -- local fb_actions = require("telescope.extensions.file_browser.actions")

    require("telescope").setup({
        defaults = {
            mappings = {
                n = {
                    ["q"] = actions.close,
                },
            },
        },
        extensions = {
            file_browser = {
                theme = "dropdown",
                hijack_netrw = true,
        --         mappings = {
        --             ["i"] = {
        --                 ["<C-w>"] = function()
        --                     vim.cmd("normal vbd")
        --                 end,
        --             },
        --             ["n"] = {
        --                 ["N"] = telescope.extensions.file_browser.actions.create,
        --                 ["h"] = telescope.extensions.file_browser.actions.goto_parent_dir,
        --                 ["/"] = function()
        --                     vim.cmd("startinsert")
        --                 end,
        --             },
        --         },
            },
        },
    })

    require("telescope").load_extension("file_browser")
end

return config