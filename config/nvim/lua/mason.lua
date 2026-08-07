local pack = require("pack")

pack.add_on_cmd(
{
  "Mason",
  "MasonInstall",
  "MasonUninstall",
  "MasonUpdate",
  "MasonLog",
},
{
  src = "mason-org/mason.nvim"
})
