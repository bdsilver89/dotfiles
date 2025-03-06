vim.g.enable_lang_java = vim.fn.executable("java") == 1

if not (vim.g.enable_lang_java ~= false) then
  return {}
end

return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = { "java" },
    },
  },

  {
    "williamboman/mason.nvim",
    opts = {
      ensure_installed = {
        "java-debug-adapter",
        "java-test",
      },
    },
  },

  {
    "mfussenegger/nvim-dap",
    optional = true,
    opts = function()
      local dap = require("dap")
      dap.configurations.java = {
        {
          type = "java",
          request = "attach",
          name = "Debug (Attach) - Remote",
          hostName = "127.0.0.1",
          port = 5005,
        },
      }
    end,
  },

  {
    "mfussenegger/nvim-jdtls",
    ft = "java",
    opts = function()
      local cmd = { vim.fn.exepath("jdtls") }
      if require("config.util").has_plugin("mason.nvim") then
        local registry = require("mason-registry")
        local lombok_jar = registry.get_package("jdtls"):get_install_path() .. "/lombok.jar"
        table.insert(cmd, string.format("--jvm-arg=-javaagent:%s", lombok_jar))
      end
      return {
        root_dir = require("lspconfig.configs." .. "jdtls").default_config.root_dir,
        project_name = function(root_dir)
          return root_dir and vim.fs.basename(root_dir)
        end,
        jdtls_config_dir = function(name)
          return vim.fn.stdpath("cache") .. "/jdtls/" .. name .. "/config"
        end,
        jdtls_workspace_dir = function(name)
          return vim.fn.stdpath("cache") .. "/jdtls/" .. name .. "/config"
        end,
        cmd = cmd,
        full_cmd = function(opts)
          local fname = vim.api.nvim_buf_get_name(0)
          local root_dir = opts.root_dir(fname)
          local project_name = opts.project_name(root_dir)
          local cmd = vim.deepcopy(opts.cmd)
          if project_name then
            vim.list_extend(cmd, {
              "-configuration",
              opts.jdtls_config_dir(project_name),
              "-data",
              opts.jdtls_workspace_dir(project_name),
            })
          end
          return cmd
        end,

        dap = {},
        dap_main = {},
        test = true,
        settings = {
          java = {
            inlayHints = {
              parameterNames = {
                enabled = "all",
              },
            },
          },
        },
      }
    end,
    config = function(_, opts)
      local bundles = {}
      if require("config.util").has_plugin("mason.nvim") then
        local registry = require("mason-registry")
        if
          opts.dap
          and require("config.util").has_plugin("nvim-dap")
          and registry.is_installed("java-debug-adapter")
        then
          local java_dbg_pkg = registry.get_package("java-debug-adapter")
          local java_dbg_path = java_dbg_pkg:get_install_path()
          local jar_patterns = {
            java_dbg_path .. "/extension/server/com.microsoft.java.debug.plugin-*.jar",
          }
          if opts.test and registry.is_installed("java-test") then
            local java_test_pkg = registry.get_package("java-test")
            local java_test_path = java_test_pkg:get_install_path()
            vim.list_extend(jar_patterns, {
              java_test_path .. "/extension/server/*.jar",
            })
          end
          for _, jar_pattern in ipairs(jar_patterns) do
            for _, bundle in ipairs(vim.split(vim.fn.glob(jar_pattern), "\n")) do
              table.insert(bundles, bundle)
            end
          end
        end
      end
      local function attach_jdtls()
        local fname = vim.api.nvim_buf_get_name(0)

        local function extend_or_override(config, custom, ...)
          if type(custom) == "function" then
            config = custom(config, ...) or config
          elseif custom then
            config = vim.tbl_deep_extend("force", config, custom)
          end
          return config
        end

        local config = extend_or_override({
          cmd = opts.full_cmd(opts),
          root_dir = opts.root_dir(fname),
          init_options = {
            bundles = bundles,
          },
          settings = opts.settings,
          capabilities = require("config.util").has_plugin("cmp-nvim-lsp")
              and require("cmp_nvim_lsp").default_capabilities()
            or nil,
        }, opts.jdtls)

        require("jdtls").start_or_attach(config)
      end

      vim.api.nvim_create_autocmd("FileType", {
        pattern = "java",
        callback = attach_jdtls,
      })

      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(event)
          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if client and client.name == "jdtls" then
            local wk = require("which-key")
            wk.add({
              {
                mode = "n",
                buffer = event.buf,
                { "<leader>cx", group = "extract" },
                { "<leader>cxv", require("jdtls").extract_variable_all, desc = "Extract Variable" },
                { "<leader>cxc", require("jdtls").extract_constant, desc = "Extract Constant" },
                { "<leader>cgs", require("jdtls").super_implementation, desc = "Goto Super" },
                { "<leader>cgS", require("jdtls.tests").goto_subjects, desc = "Goto Subjects" },
                { "<leader>co", require("jdtls").organize_imports, desc = "Organize Imports" },
              },
            })
            wk.add({
              {
                mode = "v",
                buffer = event.buf,
                { "<leader>cx", group = "extract" },
                {
                  "<leader>cxm",
                  [[<ESC><CMD>lua require('jdtls').extract_method(true)<CR>]],
                  desc = "Extract Method",
                },
                {
                  "<leader>cxv",
                  [[<ESC><CMD>lua require('jdtls').extract_variable_all(true)<CR>]],
                  desc = "Extract Variable",
                },
                {
                  "<leader>cxc",
                  [[<ESC><CMD>lua require('jdtls').extract_constant(true)<CR>]],
                  desc = "Extract Constant",
                },
              },
            })

            if require("config.util").has_plugin("mason.nvim") then
              local registry = require("mason-registry")
              if
                opts.dap
                and require("config.util").has_plugin("nvim-dap")
                and registry.is_installed("java-debug-adapter")
              then
                require("jdtls").setup_dap(opts.dap)
                if opts.dap_main then
                  require("jdtls.dap").setup_dap_main_class_configs(opts.dap_main)
                end

                if opts.test and registry.is_installed("java-test") then
                  wk.add({
                    {
                      mode = "n",
                      buffer = event.buf,
                      { "<leader>t", group = "test" },
                      {
                        "<leader>tt",
                        function()
                          require("jdtls.dap").test_class({
                            config_overrides = type(opts.test) ~= "boolean" and opts.test.config_overrides or nil,
                          })
                        end,
                        desc = "Run All Test",
                      },
                      {
                        "<leader>tr",
                        function()
                          require("jdtls.dap").test_nearest_method({
                            config_overrides = type(opts.test) ~= "boolean" and opts.test.config_overrides or nil,
                          })
                        end,
                        desc = "Run Nearest Test",
                      },
                      { "<leader>tT", require("jdtls.dap").pick_test, desc = "Run Test" },
                    },
                  })
                end
              end
            end

            -- User can set additional keymaps in opts.on_attach
            if opts.on_attach then
              opts.on_attach(event)
            end
          end
        end,
      })

      attach_jdtls()
    end,
  },
}
