local config = {}

function config.neosolarized()
    require("neosolarized").setup({
        comment_italics = true,
    })

    local cb = require('colorbuddy.init')
    local Color = cb.Color
    local colors = cb.colors
    local Group = cb.Group
    local groups = cb.groups
    local styles = cb.styles

    Color.new('black', '#000000')
    Group.new('CursorLine', colors.none, colors.base03, styles.NONE, colors.base1)
    Group.new('CursorLineNr', colors.yellow, colors.black, styles.NONE, colors.base1)
    Group.new('Visual', colors.none, colors.base03, styles.reverse)
    
    local cError = groups.Error.fg
    local cInfo = groups.Information.fg
    local cWarn = groups.Warning.fg
    local cHint = groups.Hint.fg
    
    Group.new("DiagnosticVirtualTextError", cError, cError:dark():dark():dark():dark(), styles.NONE)
    Group.new("DiagnosticVirtualTextInfo", cInfo, cInfo:dark():dark():dark(), styles.NONE)
    Group.new("DiagnosticVirtualTextWarn", cWarn, cWarn:dark():dark():dark(), styles.NONE)
    Group.new("DiagnosticVirtualTextHint", cHint, cHint:dark():dark():dark(), styles.NONE)
    Group.new("DiagnosticUnderlineError", colors.none, colors.none, styles.undercurl, cError)
    Group.new("DiagnosticUnderlineWarn", colors.none, colors.none, styles.undercurl, cWarn)
    Group.new("DiagnosticUnderlineInfo", colors.none, colors.none, styles.undercurl, cInfo)
    Group.new("DiagnosticUnderlineHint", colors.none, colors.none, styles.undercurl, cHint)	
end

function config.alpha()
    local alpha = require("alpha")
    local dashboard = require("alpha.themes.dashboard")

    local function button(sc, txt, leader_txt, keybind, keybind_opts)
        local sc_after = sc:gsub("%s", ""):gsub(leader_txt, "<leader>")

        local opts = {
            position = "center",
            shortcut = sc,
            cursor = 5,
            width = 50,
            align_shortcut = "right",
            hl_shortcut = "Keyword",
        }

        if nil == keybind then
            keybind = sc_after
        end
        keybind_opts = vim.F.if_nil(keybind_opts, { noremap = true, silent = true, nowait = true })
        opts.keymap = { "n", sc_after, keybind, keybind_opts }

        local function on_press()
            -- local key = vim.api.nvim_replace_termcodes(keybind .. '<Ignore>', true, false, true)
            local key = vim.api.nvim_replace_termcodes(sc_after .. "<Ignore>", true, false, true)
            vim.api.nvim_feedkeys(key, "t", false)
        end

        return {
            type = "button",
            val = txt,
            on_press = on_press,
            opts = opts,
        }
    end

    local leader = "Space"
    dashboard.section.buttons.val = {
        button("Space s c", " Scheme change", leader, "<cmd>Telescope colorscheme<cr>"),
        button("Space f r", " File frecency", leader, "<cmd>Telescope frecency<cr>"),
        button("Space f e", " File history", leader, "<cmd>Telescope oldfiles<cr>"),
        button("Space f p", " Project find", leader, "<cmd>Telescope project<cr>"),
        button("Space f f", " File find", leader, "<cmd>Telescope find_files<cr>"),
        button("Space f n", " File new", leader, "<cmd>enew<cr>"),
        button("Space f w", " Word find", leader, "<cmd>Telescope live_grep<cr>"),
    }
    dashboard.section.buttons.opts.hl = "String"

    local function footer()
        local total_plugins = #vim.tbl_keys(packer_plugins)
        return "   Have Fun with neovim"
            .. "   v"
            .. vim.version().major
            .. "."
            .. vim.version().minor
            .. "."
            .. vim.version().patch
            .. "   "
            .. total_plugins
            .. " plugins"
    end

    dashboard.section.footer.val = footer()
    dashboard.section.footer.opts.hl = "Function"

    local head_butt_padding = 2
    local occu_height = #dashboard.section.header.val + 2 * #dashboard.section.buttons.val + head_butt_padding
    local header_padding = math.max(0, math.ceil((vim.fn.winheight("$") - occu_height) * 0.25))
    local foot_butt_padding = 1

    dashboard.config.layout = {
        { type = "padding", val = header_padding },
        dashboard.section.header,
        { type = "padding", val = head_butt_padding },
        dashboard.section.buttons,
        { type = "padding", val = foot_butt_padding },
        dashboard.section.footer,
    }

    alpha.setup(dashboard.opts)
end

function config.notify()
    local n = require("notify")
    n.setup({
        stages = "slide",
        on_open = nil,
        on_close = nil,
        timeout = 2000,
        render = "default",
        background_colour = "Normal",
        minimum_width = 50,
        icons = {
            ERROR = "",
            WARN = "",
            INFO = "",
            DEBUG = "",
            TRACE = "✎",
        },
    })

    vim.notify = n
end


function config.indent_blankline()
    require("indent_blankline").setup({
        char = "│",
        show_first_indent_level = true,
        filetype_exclude = {
            "startify",
            "dashboard",
            "dotooagenda",
            "log",
            "fugitive",
            "gitcommit",
            "packer",
            "vimwiki",
            "markdown",
            "json",
            "txt",
            "vista",
            "help",
            "todoist",
            "NvimTree",
            "peekaboo",
            "git",
            "TelescopePrompt",
            "undotree",
            "flutterToolsOutline",
            "", -- for all buffers without a file type
        },
        buftype_exclude = { "terminal", "nofile" },
        show_trailing_blankline_indent = false,
        show_current_context = true,
        context_patterns = {
            "class",
            "function",
            "method",
            "block",
            "list_literal",
            "selector",
            "^if",
            "^table",
            "if_statement",
            "while",
            "for",
            "type",
            "var",
            "import",
        },
        space_char_blankline = " ",
    })
    -- because lazy load indent-blankline so need readd this autocmd
    vim.cmd("autocmd CursorMoved * IndentBlanklineRefresh")
end

function config.nvim_bufferline()
    require("bufferline").setup({
        options = {
            mode = "tabs",
            separator_style = 'slant',
            always_show_bufferline = false,
            show_buffer_close_icons = false,
            show_close_icon = false,
            color_icons = true
        },
        highlights = {
            separator = {
                fg = '#073642',
                bg = '#002b36',
            },
            separator_selected = {
                fg = '#073642',
            },
            background = {
                fg = '#657b83',
                bg = '#002b36'
            },
            buffer_selected = {
                fg = '#fdf6e3',
                bold = true,
            },
            fill = {
                bg = '#073642'
            }
        },
    })
end

function config.lualine()
    require("lualine").setup({
        options = {
            icons_enabled = true,
            theme = 'solarized_dark',
            section_separators = { left = '', right = '' },
            component_separators = { left = '', right = '' },
            disabled_filetypes = {}
          },
          sections = {
            lualine_a = { 'mode' },
            lualine_b = { 'branch' },
            lualine_c = { {
              'filename',
              file_status = true, -- displays file status (readonly status, modified status)
              path = 0 -- 0 = just filename, 1 = relative path, 2 = absolute path
            } },
            lualine_x = {
              { 'diagnostics', sources = { "nvim_diagnostic" }, symbols = { error = ' ', warn = ' ', info = ' ',
                hint = ' ' } },
              'encoding',
              'filetype'
            },
            lualine_y = { 'progress' },
            lualine_z = { 'location' }
          },
          inactive_sections = {
            lualine_a = {},
            lualine_b = {},
            lualine_c = { {
              'filename',
              file_status = true, -- displays file status (readonly status, modified status)
              path = 1 -- 0 = just filename, 1 = relative path, 2 = absolute path
            } },
            lualine_x = { 'location' },
            lualine_y = {},
            lualine_z = {}
          },
          tabline = {},
          extensions = { 'fugitive' }
    })
end

function config.gitsigns()
    require("gitsigns").setup()
end

function config.nvim_navic()
    vim.g.navic_silence = true
    require("nvim-navic").setup({
		icons = {
			Method = " ",
			Function = " ",
			Constructor = " ",
			Field = " ",
			Variable = " ",
			Class = "ﴯ ",
			Interface = " ",
			Module = " ",
			Property = "ﰠ ",
			Enum = " ",
			File = " ",
			EnumMember = " ",
			Constant = " ",
			Struct = " ",
			Event = " ",
			Operator = " ",
			TypeParameter = " ",
			Namespace = " ",
			Object = " ",
			Array = " ",
			Boolean = " ",
			Number = " ",
			Null = "ﳠ ",
			Key = " ",
			String = " ",
			Package = " ",
		},
		highlight = true,
		separator = " > ",
		depth_limit = 0,
		depth_limit_indicator = "..",
	})
end

function config.nvim_tree()
	require("nvim-tree").setup({
		create_in_closed_folder = false,
		respect_buf_cwd = true,
		auto_reload_on_write = true,
		disable_netrw = false,
		hijack_cursor = true,
		hijack_netrw = true,
		hijack_unnamed_buffer_when_opening = false,
		ignore_buffer_on_setup = false,
		open_on_setup = false,
		open_on_setup_file = false,
		open_on_tab = false,
		sort_by = "name",
		update_cwd = true,
		view = {
			adaptive_size = false,
			centralize_selection = false,
			width = 30,
			height = 30,
			side = "left",
			preserve_window_proportions = false,
			number = false,
			relativenumber = false,
			signcolumn = "yes",
			hide_root_folder = false,
			float = {
				enable = false,
				open_win_config = {
					relative = "editor",
					border = "rounded",
					width = 30,
					height = 30,
					row = 1,
					col = 1,
				},
			},
		},
		renderer = {
			add_trailing = false,
			group_empty = true,
			highlight_git = false,
			full_name = false,
			highlight_opened_files = "none",
			special_files = { "Cargo.toml", "Makefile", "README.md", "readme.md", "CMakeLists.txt" },
			symlink_destination = true,
			indent_markers = {
				enable = true,
				icons = {
					corner = "└ ",
					edge = "│ ",
					item = "│ ",
					none = "  ",
				},
			},
			root_folder_modifier = ":e",
			icons = {
				webdev_colors = true,
				git_placement = "before",
				show = {
					file = true,
					folder = true,
					folder_arrow = false,
					git = true,
				},
				padding = " ",
				symlink_arrow = "  ",
				glyphs = {
					default = "", --
					symlink = "",
					bookmark = "",
					git = {
						unstaged = "",
						staged = "", --
						unmerged = "שׂ",
						renamed = "", --
						untracked = "ﲉ",
						deleted = "",
						ignored = "", --◌
					},
					folder = {
						-- arrow_open = "",
						-- arrow_closed = "",
						arrow_open = "",
						arrow_closed = "",
						default = "",
						open = "",
						empty = "",
						empty_open = "",
						symlink = "",
						symlink_open = "",
					},
				},
			},
		},
		hijack_directories = {
			enable = true,
			auto_open = true,
		},
		update_focused_file = {
			enable = true,
			update_cwd = true,
			ignore_list = {},
		},
		ignore_ft_on_setup = {},
		filters = {
			dotfiles = false,
			custom = { ".DS_Store" },
			exclude = {},
		},
		actions = {
			use_system_clipboard = true,
			change_dir = {
				enable = true,
				global = false,
			},
			open_file = {
				quit_on_open = false,
				resize_window = false,
				window_picker = {
					enable = true,
					chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890",
					exclude = {
						filetype = { "notify", "packer", "qf", "diff", "fugitive", "fugitiveblame" },
						buftype = { "nofile", "terminal", "help" },
					},
				},
			},
			remove_file = {
				close_window = true,
			},
		},
		diagnostics = {
			enable = false,
			show_on_dirs = false,
			debounce_delay = 50,
			icons = {
				hint = "",
				info = "",
				warning = "",
				error = "",
			},
		},
		filesystem_watchers = {
			enable = true,
			debounce_delay = 50,
		},
		git = {
			enable = true,
			ignore = true,
			show_on_dirs = true,
			timeout = 400,
		},
		trash = {
			cmd = "gio trash",
			require_confirm = true,
		},
		live_filter = {
			prefix = "[FILTER]: ",
			always_show_folders = true,
		},
		log = {
			enable = false,
			truncate = false,
			types = {
				all = false,
				config = false,
				copy_paste = false,
				dev = false,
				diagnostics = false,
				git = false,
				profile = false,
				watcher = false,
			},
		},
	})
end

function config.scrollview()
	require("scrollview").setup({})
end

function config.fidget()
	require("fidget").setup({})
end

return config