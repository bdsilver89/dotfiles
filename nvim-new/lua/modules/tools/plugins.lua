local tools = {}
local conf = require("modules.tools.config")

tools["nvim-lua/plenary.nvim"] = { opt = false }

tools["nvim-telescope/telescope.nvim"] = {
    opt = true,
    module = "telescope",
    cmd = "Telescope",
    config = conf.telescope,
    requires = {
        {
            "nvim-lua/plenary.nvim",
            opt = false,
        }
    }
}

tools["nvim-telescope/telescope-file-browser.nvim"] = {
    opt = true,
}

tools["dstein64/vim-startuptime"] = { opt = true, cmd = "StartupTime" }

return tools