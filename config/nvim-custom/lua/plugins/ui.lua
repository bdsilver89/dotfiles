return {
  {
    "echasnovski/mini.icons",
    lazy = true,
    opts = {
      style = vim.g.has_nerd_font and "glyph" or "ascii",
    },
    init = function()
      package.preload["nvim-web-devicons"] = function()
        require("mini.icons").mock_nvim_web_devicons()
        return package.loaded["nvim-web-devicons"]
      end
    end,
  },

  -- winbar
  {
    "utilyre/barbecue.nvim",
    dependencies = {
      "SmiteshP/nvim-navic",
    },
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
        -- stylua: ignore
        close_command = function(n) Snacks.bufdelete(n) end,
        -- stylua: ignore
        right_mouse_command = function(n) Snacks.bufdelete(n) end,
        diagnostics = "nvim_lsp",
        always_show_bufferline = false,
        -- diagnostics_indicator = function(_, _, diag)
        --   local icons = LazyVim.config.icons.diagnostics
        --   local ret = (diag.error and icons.Error .. diag.error .. " " or "")
        --     .. (diag.warning and icons.Warn .. diag.warning or "")
        --   return vim.trim(ret)
        -- end,
        offsets = {
          {
            filetype = "NvimTree",
            text = "NvimTree",
            highlight = "Directory",
            text_align = "left",
          },
        },
        ---@param opts bufferline.IconFetcherOpts
        -- get_element_icon = function(opts)
        --   return LazyVim.config.icons.ft[opts.filetype]
        -- end,
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
          component_separators = "",
          section_separators = { left = "", right = "" },
          disabled_filetypes = {
            "Lazy",
            "Mason",
            "NvimTree",
            "help",
            "man",
            "dap-repl",
            "dapui_scopes",
            "dapui_breakpoints",
            "dapui_stacks",
            "dapui_watches",
            "dapui_console",
          },
          ignore_focus = {
            "Lazy",
            "Mason",
            "NvimTree",
            "help",
            "man",
            "dap-repl",
            "dapui_scopes",
            "dapui_breakpoints",
            "dapui_stacks",
            "dapui_watches",
            "dapui_console",
          },
        },
        sections = {
          lualine_a = {
            {
              "mode",
              padding = { left = 2, right = 2 },
              separator = { left = "", right = icons.separators.rounded.right },
              icon = "",
              color = { gui = "italic" },
            },
          },
          lualine_b = {
            {
              "branch",
              icon = icons.git.branch,
              -- color = { bg = bg, fg = colors.accent, gui = "italic" },
              color = { gui = "italic" },
              padding = { left = 1, right = 1 },
              separator = { left = "", right = icons.separators.rounded.right },
            },
            {
              "diff",
              symbols = {
                added = icons.misc.large_circle,
                modified = icons.misc.large_circle,
                removed = icons.misc.large_circle,
              },
              -- symbols = { added = icons.git.added, modified = icons.git.modified, removed = icons.git.removed },
              -- color = { bg = bg, gui = "italic" },
              color = { gui = "italic" },
              separator = { left = "", right = icons.separators.rounded.right },
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
            { "filename" },
          },

          lualine_x = {
            {
              "diagnostics",
              sources = { "nvim_diagnostic" },
              symbols = {
                error = icons.misc.large_circle,
                warn = icons.misc.large_circle,
                hint = icons.misc.large_circle,
                info = icons.misc.large_circle,
              },
              sections = { "error", "warn", "info", "hint" },
              padding = { left = 2, right = 1 },
              separator = { right = "", left = "" },
              diagnostics_color = {
                error = "DiagnosticSignError",
                warn = "DiagnosticSignWarn",
                info = "DiagnosticSignInfo",
                hint = "DiagnosticSignHint",
              },
              -- colored = true, -- Displays diagnostics status in color if set to true.
              update_in_insert = true, -- Update diagnostics in insert mode.
              -- always_visible = false, -- Show diagnostics even if there are none.
            },
          },
          lualine_y = {
            {
              function()
                return vim.fn.fnamemodify(vim.fn.getcwd(), ":t") .. " "
              end,
              icon = "󰉖 ",
              separator = { left = icons.separators.rounded.left },
              padding = { left = 1, right = 1 },
              -- color = { bg = colors.yellow, fg = colors.bg, gui = "italic" },
              color = { gui = "italic" },
            },
          },
          lualine_z = {
            {
              "progress",
              -- separator = " ",
              padding = { left = 1, right = 1 },
              separator = { left = icons.separators.rounded.left },
            },
            { "location", padding = { left = 0, right = 1 } },
          },
        },
      }
    end,
  },

  {
    "echasnovski/mini.hipatterns",
    event = { "BufReadPost", "BufNewFile" },
    opts = function()
      local hi = require("mini.hipatterns")
      return {
        tailwind = {
          enabled = true,
          ft = {
            "css",
            "html",
            "javascript",
            "javascriptreact",
            "rust",
            "svelte",
            "typescript",
            "typescriptreact",
            "vue",
          },
          style = "full",
        },
        highlighters = {
          hex = hi.gen_highlighter.hex_color({ priority = 2000 }),
          shorthand = {
            pattern = "()#%x%x%x()%f[^%x%w]",
            group = function(_, _, data)
              local match = data.full_match
              local r, g, b = match:sub(2, 2), match:sub(3, 3), match:sub(4, 4)
              local hex_color = "#" .. r .. r .. g .. g .. b .. b

              return MiniHipatterns.compute_hex_color_group(hex_color, "bg")
            end,
            extmark_opts = { priority = 2000 },
          },
        },
      }
    end,
    config = function(_, opts)
      local M = {}

      M.hl = {}

      M.colors = {
        slate = {
          [50] = "f8fafc",
          [100] = "f1f5f9",
          [200] = "e2e8f0",
          [300] = "cbd5e1",
          [400] = "94a3b8",
          [500] = "64748b",
          [600] = "475569",
          [700] = "334155",
          [800] = "1e293b",
          [900] = "0f172a",
          [950] = "020617",
        },

        gray = {
          [50] = "f9fafb",
          [100] = "f3f4f6",
          [200] = "e5e7eb",
          [300] = "d1d5db",
          [400] = "9ca3af",
          [500] = "6b7280",
          [600] = "4b5563",
          [700] = "374151",
          [800] = "1f2937",
          [900] = "111827",
          [950] = "030712",
        },

        zinc = {
          [50] = "fafafa",
          [100] = "f4f4f5",
          [200] = "e4e4e7",
          [300] = "d4d4d8",
          [400] = "a1a1aa",
          [500] = "71717a",
          [600] = "52525b",
          [700] = "3f3f46",
          [800] = "27272a",
          [900] = "18181b",
          [950] = "09090B",
        },

        neutral = {
          [50] = "fafafa",
          [100] = "f5f5f5",
          [200] = "e5e5e5",
          [300] = "d4d4d4",
          [400] = "a3a3a3",
          [500] = "737373",
          [600] = "525252",
          [700] = "404040",
          [800] = "262626",
          [900] = "171717",
          [950] = "0a0a0a",
        },

        stone = {
          [50] = "fafaf9",
          [100] = "f5f5f4",
          [200] = "e7e5e4",
          [300] = "d6d3d1",
          [400] = "a8a29e",
          [500] = "78716c",
          [600] = "57534e",
          [700] = "44403c",
          [800] = "292524",
          [900] = "1c1917",
          [950] = "0a0a0a",
        },

        red = {
          [50] = "fef2f2",
          [100] = "fee2e2",
          [200] = "fecaca",
          [300] = "fca5a5",
          [400] = "f87171",
          [500] = "ef4444",
          [600] = "dc2626",
          [700] = "b91c1c",
          [800] = "991b1b",
          [900] = "7f1d1d",
          [950] = "450a0a",
        },

        orange = {
          [50] = "fff7ed",
          [100] = "ffedd5",
          [200] = "fed7aa",
          [300] = "fdba74",
          [400] = "fb923c",
          [500] = "f97316",
          [600] = "ea580c",
          [700] = "c2410c",
          [800] = "9a3412",
          [900] = "7c2d12",
          [950] = "431407",
        },

        amber = {
          [50] = "fffbeb",
          [100] = "fef3c7",
          [200] = "fde68a",
          [300] = "fcd34d",
          [400] = "fbbf24",
          [500] = "f59e0b",
          [600] = "d97706",
          [700] = "b45309",
          [800] = "92400e",
          [900] = "78350f",
          [950] = "451a03",
        },

        yellow = {
          [50] = "fefce8",
          [100] = "fef9c3",
          [200] = "fef08a",
          [300] = "fde047",
          [400] = "facc15",
          [500] = "eab308",
          [600] = "ca8a04",
          [700] = "a16207",
          [800] = "854d0e",
          [900] = "713f12",
          [950] = "422006",
        },

        lime = {
          [50] = "f7fee7",
          [100] = "ecfccb",
          [200] = "d9f99d",
          [300] = "bef264",
          [400] = "a3e635",
          [500] = "84cc16",
          [600] = "65a30d",
          [700] = "4d7c0f",
          [800] = "3f6212",
          [900] = "365314",
          [950] = "1a2e05",
        },

        green = {
          [50] = "f0fdf4",
          [100] = "dcfce7",
          [200] = "bbf7d0",
          [300] = "86efac",
          [400] = "4ade80",
          [500] = "22c55e",
          [600] = "16a34a",
          [700] = "15803d",
          [800] = "166534",
          [900] = "14532d",
          [950] = "052e16",
        },

        emerald = {
          [50] = "ecfdf5",
          [100] = "d1fae5",
          [200] = "a7f3d0",
          [300] = "6ee7b7",
          [400] = "34d399",
          [500] = "10b981",
          [600] = "059669",
          [700] = "047857",
          [800] = "065f46",
          [900] = "064e3b",
          [950] = "022c22",
        },

        teal = {
          [50] = "f0fdfa",
          [100] = "ccfbf1",
          [200] = "99f6e4",
          [300] = "5eead4",
          [400] = "2dd4bf",
          [500] = "14b8a6",
          [600] = "0d9488",
          [700] = "0f766e",
          [800] = "115e59",
          [900] = "134e4a",
          [950] = "042f2e",
        },

        cyan = {
          [50] = "ecfeff",
          [100] = "cffafe",
          [200] = "a5f3fc",
          [300] = "67e8f9",
          [400] = "22d3ee",
          [500] = "06b6d4",
          [600] = "0891b2",
          [700] = "0e7490",
          [800] = "155e75",
          [900] = "164e63",
          [950] = "083344",
        },

        sky = {
          [50] = "f0f9ff",
          [100] = "e0f2fe",
          [200] = "bae6fd",
          [300] = "7dd3fc",
          [400] = "38bdf8",
          [500] = "0ea5e9",
          [600] = "0284c7",
          [700] = "0369a1",
          [800] = "075985",
          [900] = "0c4a6e",
          [950] = "082f49",
        },

        blue = {
          [50] = "eff6ff",
          [100] = "dbeafe",
          [200] = "bfdbfe",
          [300] = "93c5fd",
          [400] = "60a5fa",
          [500] = "3b82f6",
          [600] = "2563eb",
          [700] = "1d4ed8",
          [800] = "1e40af",
          [900] = "1e3a8a",
          [950] = "172554",
        },

        indigo = {
          [50] = "eef2ff",
          [100] = "e0e7ff",
          [200] = "c7d2fe",
          [300] = "a5b4fc",
          [400] = "818cf8",
          [500] = "6366f1",
          [600] = "4f46e5",
          [700] = "4338ca",
          [800] = "3730a3",
          [900] = "312e81",
          [950] = "1e1b4b",
        },

        violet = {
          [50] = "f5f3ff",
          [100] = "ede9fe",
          [200] = "ddd6fe",
          [300] = "c4b5fd",
          [400] = "a78bfa",
          [500] = "8b5cf6",
          [600] = "7c3aed",
          [700] = "6d28d9",
          [800] = "5b21b6",
          [900] = "4c1d95",
          [950] = "2e1065",
        },

        purple = {
          [50] = "faf5ff",
          [100] = "f3e8ff",
          [200] = "e9d5ff",
          [300] = "d8b4fe",
          [400] = "c084fc",
          [500] = "a855f7",
          [600] = "9333ea",
          [700] = "7e22ce",
          [800] = "6b21a8",
          [900] = "581c87",
          [950] = "3b0764",
        },

        fuchsia = {
          [50] = "fdf4ff",
          [100] = "fae8ff",
          [200] = "f5d0fe",
          [300] = "f0abfc",
          [400] = "e879f9",
          [500] = "d946ef",
          [600] = "c026d3",
          [700] = "a21caf",
          [800] = "86198f",
          [900] = "701a75",
          [950] = "4a044e",
        },

        pink = {
          [50] = "fdf2f8",
          [100] = "fce7f3",
          [200] = "fbcfe8",
          [300] = "f9a8d4",
          [400] = "f472b6",
          [500] = "ec4899",
          [600] = "db2777",
          [700] = "be185d",
          [800] = "9d174d",
          [900] = "831843",
          [950] = "500724",
        },

        rose = {
          [50] = "fff1f2",
          [100] = "ffe4e6",
          [200] = "fecdd3",
          [300] = "fda4af",
          [400] = "fb7185",
          [500] = "f43f5e",
          [600] = "e11d48",
          [700] = "be123c",
          [800] = "9f1239",
          [900] = "881337",
          [950] = "4c0519",
        },
      }

      if type(opts.tailwind) == "table" and opts.tailwind.enabled then
        vim.api.nvim_create_autocmd("ColorScheme", {
          callback = function()
            M.hl = {}
          end,
        })

        opts.highlighters.tailwind = {
          pattern = function()
            if not vim.tbl_contains(opts.tailwind.ft, vim.bo.filetype) then
              return
            end
            if opts.tailwind.style == "full" then
              return "%f[%w:-]()[%w:-]+%-[a-z%-]+%-%d+()%f[^%w:-]"
            elseif opts.tailwind.style == "compact" then
              return "%f[%w:-][%w:-]+%-()[a-z%-]+%-%d+()%f[^%w:-]"
            end
          end,
          group = function(_, _, m)
            ---@type string
            local match = m.full_match
            ---@type string, number
            local color, shade = match:match("[%w-]+%-([a-z%-]+)%-(%d+)")
            shade = tonumber(shade)
            local bg = vim.tbl_get(M.colors, color, shade)
            if bg then
              local hl = "MiniHipatternsTailwind" .. color .. shade
              if not M.hl[hl] then
                M.hl[hl] = true
                local bg_shade = shade == 500 and 950 or shade < 500 and 900 or 100
                local fg = vim.tbl_get(M.colors, color, bg_shade)
                vim.api.nvim_set_hl(0, hl, { bg = "#" .. bg, fg = "#" .. fg })
              end
              return hl
            end
          end,
          extmark_opts = { priority = 2000 },
        }
      end
      require("mini.hipatterns").setup(opts)
    end,
  },
}
