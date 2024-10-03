return {
  -- icons
  {
    "echasnovski/mini.icons",
    lazy = true,
    opts = {
      style = vim.g.enable_icons and "glyph" or "ascii",
      file = {
        [".keep"] = { glyph = "󰊢", hl = "MiniIconsGrey" },
        ["devcontainer.json"] = { glyph = "", hl = "MiniIconsAzure" },
      },
      filetype = {
        dotenv = { glyph = "", hl = "MiniIconsYellow" },
        gotmpl = { glyph = "󰟓", hl = "MiniIconsGrey" },
      },
    },
    init = function()
      package.preload["nvim-web-devicons"] = function()
        require("mini.icons").mock_nvim_web_devicons()
        return package.loaded["nvim-web-devicons"]
      end
    end,
  },

  -- ui components
  { "MunifTanjim/nui.nvim", lazy = true },

  -- indent guides
  {
    "lukas-reineke/indent-blankline.nvim",
    event = "LazyFile",
    opts = {
      indent = {
        char = "│",
        tab_char = "│",
      },
      scope = { show_start = false, show_end = false },
      exclude = {
        filetypes = {
          "help",
          "alpha",
          "dashboard",
          "neo-tree",
          "Trouble",
          "trouble",
          "lazy",
          "mason",
          "notify",
          "toggleterm",
          "lazyterm",
        },
      },
    },
    main = "ibl",
  },

  {
    "nvim-lualine/lualine.nvim",
    enabled = true,
    event = "VeryLazy",
    -- init = function()
    --   vim.g.lualine_laststatus = vim.o.laststatus
    --   if vim.fn.argc(-1) > 0 then
    --     vim.o.statusline = " "
    --   else
    --     vim.o.laststatus = 0
    --   end
    -- end,
    opts = function()
      local lualine_require = require("lualine_require")
      lualine_require.require = require
      -- vim.o.laststatus = vim.g.lualine_laststatus

      local path_separator = vim.g.enable_icons and "" or ">"

      local trouble = require("trouble")
      local symbols = trouble.statusline({
        mode = "lsp_document_symbols",
        groups = {},
        title = false,
        filter = { range = true },
        format = path_separator .. " {kind_icon}{symbol.name:Normal}",
        -- The following line is needed to fix the background color
        -- Set it to the lualine section you want to use
        hl_group = "lualine_c_normal",
      })

      local function rel_path_no_filename(split)
        return {
          function()
            local file_path = vim.fn.expand("%:~:.:h")
            file_path = file_path:gsub("^%.", "")
            file_path = file_path:gsub("^%/", "")

            if not split then
              return file_path
            end

            local file_path_list = {}
            local _ = string.gsub(file_path, "[^/]+", function(w)
              table.insert(file_path_list, w)
            end)

            local result = ""
            for i = 1, #file_path_list do
              result = result .. file_path_list[i] .. " " .. path_separator .. " "
            end
            return result
          end,
          padding = { right = 0 },
        }
      end

      local function fileicon()
        return {
          "filetype",
          icon_only = true,
          separator = "",
          padding = { left = 0, right = 0 },
        }
      end

      local opts = {
        options = {
          theme = "auto",
          icons_enabled = vim.g.enable_icons,
          globalstatus = vim.o.laststatus == 3,
          component_separators = "",
          section_separators = "",
          disabled_filetypes = { "dashboard" },
        },
        sections = {
          lualine_a = { "mode" },
          lualine_b = {
            "branch",
            {
              "diff",
              symbols = {
                added = vim.g.enable_icons and " " or "+",
                modified = vim.g.enable_icons and " " or "~",
                removed = vim.g.enable_icons and " " or "-",
              },
              source = function()
                local gitsigns = vim.b.gitsigns_status_dict
                if gitsigns then
                  return {
                    added = gitsigns.added,
                    modified = gitsigns.changed,
                    removed = gitsigns.removed,
                  }
                end
              end,
            },
            "diagnostics",
          },
          lualine_c = {
            {
              "filename",
              path = 1,
            },
          },
          lualine_x = {
            "encoding",
            "fileformat",
            "filetype",
          },
          lualine_y = { "progress" },
          lualine_z = { "location" },
        },
        winbar = {
          lualine_c = {
            rel_path_no_filename(true),
            fileicon(),
            "filename",
            {
              symbols.get,
              cond = symbols.has,
            },
          },
        },
        inactive_winbar = {
          lualine_c = {
            rel_path_no_filename(true),
            fileicon(),
            "filename",
          },
        },
        extensions = {
          "lazy",
          "oil",
          "nvim-tree",
        },
      }

      return opts
    end,
  },
}
