local add = MiniDeps.add

add("stevearc/overseer.nvim")

local function get_cmake_build_dir()
  local build_dirs = { "build", "Build", "cmake-build", "_build" }
  for _, dir in ipairs(build_dirs) do
    if vim.fn.isdirectory(dir) == 1 then
      return dir
    end
  end
  return "build"
end

local function has_cmake_project()
  return vim.fn.filereadable("CMakeLists.txt") == 1
end

local cmake_templates = {
  {
    name = "cmake configure",
    builder = function(params)
      local build_dir = params.build_dir or get_cmake_build_dir()
      return {
        cmd = "cmake",
        args = { "-S", ".", "-B", build_dir },
        name = "CMake Configure",
        components = {
          { "on_output_quickfix", open = false },
          "on_result_diagnostics",
          "default",
        },
      }
    end,
    desc = "Configure CMake project",
    params = {
      build_dir = {
        type = "string",
        optional = true,
        desc = "Build directory (default: auto-detect or 'build')",
      },
    },
    condition = {
      callback = has_cmake_project,
    },
  },
  {
    name = "cmake build",
    builder = function(params)
      local build_dir = params.build_dir or get_cmake_build_dir()
      local target = params.target or "all"
      local args = { "--build", build_dir }
      if target ~= "all" then
        table.insert(args, "--target")
        table.insert(args, target)
      end
      if params.parallel then
        table.insert(args, "--parallel")
      end
      return {
        cmd = "cmake",
        args = args,
        name = target == "all" and "CMake Build" or ("CMake Build: " .. target),
        components = {
          { "on_output_quickfix", open = true },
          "on_result_diagnostics",
          "default",
        },
      }
    end,
    desc = "Build CMake project",
    params = {
      build_dir = {
        type = "string",
        optional = true,
        desc = "Build directory (default: auto-detect or 'build')",
      },
      target = {
        type = "string",
        optional = true,
        desc = "Build target (default: all)",
      },
      parallel = {
        type = "boolean",
        optional = true,
        default = true,
        desc = "Build in parallel",
      },
    },
    condition = {
      callback = function()
        return has_cmake_project() and vim.fn.isdirectory(get_cmake_build_dir()) == 1
      end,
    },
  },
  {
    name = "cmake test",
    builder = function(params)
      local build_dir = params.build_dir or get_cmake_build_dir()
      return {
        cmd = "ctest",
        args = { "--test-dir", build_dir, "--output-on-failure" },
        name = "CMake Test",
        components = {
          { "on_output_quickfix", open = true },
          "default",
        },
      }
    end,
    desc = "Run CMake tests",
    params = {
      build_dir = {
        type = "string",
        optional = true,
        desc = "Build directory (default: auto-detect or 'build')",
      },
    },
    condition = {
      callback = function()
        return has_cmake_project() and vim.fn.isdirectory(get_cmake_build_dir()) == 1
      end,
    },
  },
  {
    name = "cmake clean",
    builder = function(params)
      local build_dir = params.build_dir or get_cmake_build_dir()
      return {
        cmd = "cmake",
        args = { "--build", build_dir, "--target", "clean" },
        name = "CMake Clean",
        components = { "default" },
      }
    end,
    desc = "Clean CMake build",
    params = {
      build_dir = {
        type = "string",
        optional = true,
        desc = "Build directory (default: auto-detect or 'build')",
      },
    },
    condition = {
      callback = function()
        return has_cmake_project() and vim.fn.isdirectory(get_cmake_build_dir()) == 1
      end,
    },
  },
}

for _, template in ipairs(cmake_templates) do
  require("overseer").register_template(template)
end

require("overseer").setup({
  task_list = {
    direction = "bottom",
  },
})

vim.keymap.set("n", "<leader>ot", "<cmd>OverseerToggle<cr>", { desc = "Overseer toggle" })
vim.keymap.set("n", "<leader>oc", "<cmd>OverseerRunCmd<cr>", { desc = "Overseer run command" })
vim.keymap.set("n", "<leader>or", "<cmd>OverseerRun<cr>", { desc = "Overseer run" })
vim.keymap.set("n", "<leader>oq", "<cmd>OverseerQuickAction<cr>", { desc = "Overseer quick action" })
vim.keymap.set("n", "<leader>oa", "<cmd>OverseerTaskAction<cr>", { desc = "Overseer task action" })
vim.keymap.set("n", "<leader>ok", "<cmd>OverseerInfo<cr>", { desc = "Overseer info" })

vim.api.nvim_create_user_command("Make", function(params)
  -- Insert args at the '$*' in the makeprg
  local cmd, num_subs = vim.o.makeprg:gsub("%$%*", params.args)
  if num_subs == 0 then
    cmd = cmd .. " " .. params.args
  end
  local task = require("overseer").new_task({
    cmd = vim.fn.expandcmd(cmd),
    components = {
      { "on_output_quickfix", open = not params.bang, open_height = 8 },
      "default",
    },
  })
  task:start()
end, {
  desc = "Run your makeprg as an Overseer task",
  nargs = "*",
  bang = true,
})
