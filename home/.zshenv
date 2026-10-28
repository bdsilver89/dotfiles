[[ -n $ETC_PROFILE_SOURCED ]] && unsetopt GLOBAL_RCS
[[ -o login ]] || . "$HOME/.config/shell/env.sh"
