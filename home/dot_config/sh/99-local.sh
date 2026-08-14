# Untracked, machine-local. Work proxies, internal registries, tokens, API keys.
#
# This lives in its own file rather than at the end of env.sh because the loader
# sources ~/.config/sh/*.sh in glob order, which is alphabetical. Inside env.sh
# it would run BEFORE path.sh and tools.sh and so could not override PATH or the
# tool init. The zz- prefix guarantees it is genuinely last.
[ -f "$XDG_CONFIG_HOME/sh/local.sh" ] && . "$XDG_CONFIG_HOME/sh/local.sh"
