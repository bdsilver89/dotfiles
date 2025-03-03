return {
  {
    "mini.nvim",
    opts = {
      icons = {
        style = vim.g.has_nerd_font and "glyph" or "ascii",
      },
      hipatterns = {
        highlighters = {
          fixme = { pattern = "FIXME", group = "MiniHipatternsFixme" },
          hack = { pattern = "HACK", group = "MiniHipatternsHack" },
          todo = { pattern = "TODO", group = "MiniHipatternsTodo" },
          note = { pattern = "NOTE", group = "MiniHipatternsNote" },
        },
      },
    },
    init = function()
      package.preload["nvim-web-devicons"] = function()
        require("mini.icons").mock_nvim_web_devicons()
        return package.loaded["nvim-web-devicons"]
      end
    end,
  },

  {
    "snacks.nvim",
    opts = {
      indent = { enabled = true },
      dashboard = {},
      scope = { enabled = true },
      statuscolumn = { enabled = true },
      words = { enabled = true },
    },
  },

  {
    "Bekaboo/dropbar.nvim",
    event = "LazyFile",
    opts = {},
  },

  -- bufferline
  {
    "akinsho/bufferline.nvim",
    event = "VeryLazy",
    keys = {
      { "<leader>bp", "<Cmd>BufferLineTogglePin<CR>", desc = "Toggle Pin" },
      { "<leader>bP", "<Cmd>BufferLineGroupClose ungrouped<CR>", desc = "Delete Non-Pinned Buffers" },
      { "<leader>br", "<Cmd>BufferLineCloseRight<CR>", desc = "Delete Buffers to the Right" },
      { "<leader>bl", "<Cmd>BufferLineCloseLeft<CR>", desc = "Delete Buffers to the Left" },
      { "<S-h>", "<cmd>BufferLineCyclePrev<cr>", desc = "Prev Buffer" },
      { "<S-l>", "<cmd>BufferLineCycleNext<cr>", desc = "Next Buffer" },
      { "[b", "<cmd>BufferLineCyclePrev<cr>", desc = "Prev Buffer" },
      { "]b", "<cmd>BufferLineCycleNext<cr>", desc = "Next Buffer" },
      { "[B", "<cmd>BufferLineMovePrev<cr>", desc = "Move buffer prev" },
      { "]B", "<cmd>BufferLineMoveNext<cr>", desc = "Move buffer next" },
    },
    opts = {
      options = {
        close_command = function(n)
          if Snacks then
            Snacks.bufdelete(n)
          else
            vim.cmd("bdelete! " .. n)
          end
        end,
        right_mouse_command = function(n)
          if Snacks then
            Snacks.bufdelete(n)
          else
            vim.cmd("bdelete! " .. n)
          end
        end,
        diagnostics = "nvim_lsp",
        always_show_bufferline = false,
        diagnostics_indicator = function(_, _, diag)
          local icons = require("config.icons").diagnostics
          local ret = (diag.error and icons.error .. diag.error .. " " or "")
            .. (diag.warning and icons.warn .. diag.warning or "")
          return vim.trim(ret)
        end,
        offsets = {
          {
            filetype = "NvimTree",
            text = "NvimTree",
            highlight = "Directory",
            text_align = "left",
          },
          {
            filetype = "snacks_layout_box",
          },
        },
      },
    },
    config = function(_, opts)
      require("bufferline").setup(opts)
      -- Fix bufferline when restoring a session
      vim.api.nvim_create_autocmd({ "BufAdd", "BufDelete" }, {
        callback = function()
          vim.schedule(function()
            pcall(nvim_bufferline)
          end)
        end,
      })
    end,
  },

  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    init = function()
      vim.g.lualine_laststatus = vim.o.laststatus
      if vim.fn.argc(-1) > 0 then
        -- set an empty statusline till lualine loads
        vim.o.statusline = " "
      else
        -- hide the statusline on the starter page
        vim.o.laststatus = 0
      end
    end,
    opts = function()
      -- PERF: we don't need this lualine require madness 🤷
      local lualine_require = require("lualine_require")
      lualine_require.require = require

      local icons = require("config.icons")

      return {
        options = {
          theme = "auto",
          globalstatus = vim.o.laststatus == 3,
          section_separators = "",
          component_separators = "",
          disabled_filetypes = {
            "Lazy",
            "Mason",
            "NvimTree",
            "help",
            "man",
            "oil",
            "dap-repl",
            "dapui_scopes",
            "dapui_breakpoints",
            "dapui_stacks",
            "dapui_watches",
            "dapui_console",
            "snacks_dashboard",
          },
          ignore_focus = {
            "Lazy",
            "Mason",
            "NvimTree",
            "help",
            "man",
            "oil",
            "dap-repl",
            "dapui_scopes",
            "dapui_breakpoints",
            "dapui_stacks",
            "dapui_watches",
            "dapui_console",
            "snacks_dashboard",
          },
        },
        sections = {
          lualine_a = {
            {
              "mode",
              icon = icons.misc.vim,
              color = { gui = "italic" },
            },
          },
          lualine_b = {
            {
              "branch",
              icon = icons.git.branch,
              color = { gui = "italic" },
            },
            {
              "diff",
              symbols = icons.git,
              color = { gui = "italic" },
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
          },
          lualine_c = {
            { "filetype", icon_only = true, separator = "", padding = { left = 1, right = 0 } },
            { "filename", separator = "" },
            {
              "diagnostics",
              sources = { "nvim_diagnostic" },
              -- symbols = icons.diagnostics,
              sections = { "error", "warn", "info", "hint" },
              update_in_insert = true, -- Update diagnostics in insert mode.
            },
          },
          lualine_x = {
            { "encoding" },
            { "fileformat", symbols = { unix = "unix", dos = "dos", mac = "mac" } },
          },
          lualine_y = {
            {
              function()
                return vim.fn.fnamemodify(vim.fn.getcwd(), ":t") .. " "
              end,
              icon = icons.misc.folder,
              color = { gui = "italic" },
            },
          },
          lualine_z = {
            { "progress" },
            { "location" },
          },
        },
      }
    end,
  },
}
