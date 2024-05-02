-- stylua: ignore start

-- icon configuration
vim.g.enable_icons = true           -- set to 'true' when a nerd font is installed

-- package download configuration
vim.g.enable_mason_packages = true  -- enable/disable downloading LSPs/formatters/linters from mason

-- language/addon configuration
vim.g.enable_lang_ansible = true    -- enable/disable ansible support
vim.g.enable_lang_c_cpp = true      -- enable/disable c/c++ support
vim.g.enable_lang_cmake = true      -- enable/disable cmake support
vim.g.enable_lang_docker = true     -- enable/disable docker support
vim.g.enable_lang_go = true         -- enable/disable go support
vim.g.enable_lang_java = true       -- enable/disable java support
vim.g.enable_lang_json = true       -- enable/disable json support
vim.g.enable_lang_markdown = true   -- enable/disable markdown support
vim.g.enable_lang_python = true     -- enable/disable python support
vim.g.enable_lang_rust = true       -- enable/disable rust support
vim.g.enable_lang_tailwind = true   -- enable/disable tailwind support
vim.g.enable_lang_terraform = true  -- enable/disable tailwind support
vim.g.enable_lang_js_ts = true      -- enable/disable javascript/typescript support
vim.g.enable_lang_yaml = true       -- enable/disable yaml support
-- stylua: ignore end

-- load config
require("config.lazy")
