local lang = {}
local conf = require("modules.lang.config")

lang["fatih/vim-go"] = {
    opt = true,
    ft = "go",
    run = ":GoInstallBinaries",
    config = conf.lang_go,
}

return lang