local config = {}

function config.nvim_treesitter()
    -- vim.api.nvim_set_option_value("foldmethod", "expr", {})
    -- vim.api.nvim_set_option_value("foldexpr", "nvim_treesitter#foldexpr()", {})

    require("nvim-treesitter.configs").setup({
        ensure_installed = {
            "bash",
            "c",
            "cpp",
            "lua",
            "go",
            "gomod",
            "json",
            "yaml",
            "latex",
            "make",
            "python",
            "rust",
            "html",
            "javascript",
            "typescript",
            "vue",
            "css",
        },
        highlight = { enable = true, disable = { "vim" } },
        textobjects = {
            select = {
                enable = true,
                keymaps = {
                    ["af"] = "@function.outer",
                    ["if"] = "@function.inner",
                    ["ac"] = "@class.outer",
                    ["ic"] = "@class.inner",
                },
            },
            move = {
                enable = true,
                set_jumps = true, -- whether to set jumps in the jumplist
                goto_next_start = {
                    ["]["] = "@function.outer",
                    ["]m"] = "@class.outer",
                },
                goto_next_end = {
                    ["]]"] = "@function.outer",
                    ["]M"] = "@class.outer",
                },
                goto_previous_start = {
                    ["[["] = "@function.outer",
                    ["[m"] = "@class.outer",
                },
                goto_previous_end = {
                    ["[]"] = "@function.outer",
                    ["[M"] = "@class.outer",
                },
            },
        },
        rainbow = {
            enable = true,
            extended_mode = true, -- Highlight also non-parentheses delimiters, boolean or table: lang -> boolean
            max_file_lines = 1000, -- Do not enable for files with more than 1000 lines, int
        },
        context_commentstring = { enable = true, enable_autocmd = false },
        matchup = { enable = true },
    })
    require("nvim-treesitter.install").prefer_git = true
    local parsers = require("nvim-treesitter.parsers").get_parser_configs()
    for _, p in pairs(parsers) do
        p.install_info.url = p.install_info.url:gsub("https://github.com/", "git@github.com:")
    end
end

function config.zen_mode()
    require("zen-mode").setup({})
end

function config.nvim_comment()
    require("nvim_comment").setup({})
end

function config.nvim_colorizer()
    require("colorizer").setup()
end


function config.toggleterm()
    require("toggleterm").setup({
        -- size can be a number or function which is passed the current terminal
        size = function(term)
            if term.direction == "horizontal" then
                return 15
            elseif term.direction == "vertical" then
                return vim.o.columns * 0.40
            end
        end,
        on_open = function()
            -- Prevent infinite calls from freezing neovim.
            -- Only set these options specific to this terminal buffer.
            vim.api.nvim_set_option_value("foldmethod", "manual", { scope = "local" })
            vim.api.nvim_set_option_value("foldexpr", "0", { scope = "local" })
        end,
        open_mapping = false, -- [[<c-\>]],
        hide_numbers = true, -- hide the number column in toggleterm buffers
        shade_filetypes = {},
        shade_terminals = false,
        shading_factor = "1", -- the degree by which to darken to terminal colour, default: 1 for dark backgrounds, 3 for light
        start_in_insert = true,
        insert_mappings = true, -- whether or not the open mapping applies in insert mode
        persist_size = true,
        direction = "horizontal",
        close_on_exit = true, -- close the terminal window when the process exits
        shell = vim.o.shell, -- change the default shell
    })
end

function config.hop()
    require("hop").setup({
        keys = "etovxqpdygfblzhckisuran"
    })
end

-- function config.accelerated_jk()
--     require("accelerated-jk").setup({
--         mode = "time_driven",
--         enable_deceleration = false,
--         acceleration_motions = {},
--         acceleration_limit = 150,
--         acceleration_table = { 7, 12, 17, 21, 24, 16, 28, 30, },
--         deceleration_table = { { 150, 9999, } },
--     })
-- end

return config
