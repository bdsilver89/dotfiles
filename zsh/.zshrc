# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

export ZSH="$HOME/.oh-my-zsh"

# ZSH_THEME="agnoster"
ZSH_THEME="eastwood"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

plugins=(asdf git web-search zsh-autosuggestions)

source $ZSH/oh-my-zsh.sh

# export MANPATH="/usr/local/man:$MANPATH"

# general aliases
alias cl="clear"
alias pg="ps -ef | grep"
alias pkill!="pkill -9 -f"

# editor setup
if [ -x "$(command -v nvim)" ]; then
  export EDITOR='nvim'
  # add asdf update aliases if
  if [ -x "$(command -v asdf)" ]; then
    alias update-nvim-stable='asdf uninstall neovim ref:stable && asdf install ref:stable'
    alias update-nvim-nightly='asdf uninstall neovim ref:nightly && asdf install ref:nightly'
    alias update-nvim-master='asdf uninstall neovim ref:master && asdf install ref:master'
  fi
elif [ -x "$(command -v vim)" ]; then
  export EDITOR='vim'
else
  export EDITOR='vi'
fi

# tool setup
if [ -x "$(command -v exa)" ]; then
  alias ls="exa"
fi
if [ -x "$(command -v bat)" ]; then
  alias cat="bat"
fi
if [ -x "$(command -v tmux)" ]; then
  alias ide="tmux split-window -v -p 30"
fi
if [ -x "$(command -v starship)" ]; then
  eval "(starship init zsh)"
fi

# pyenv setup
# export PYENV_ROOT="$HOME/.pyenv"
# command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
# eval "$(pyenv init -)"

# poetry setup
# export POETRY_ROOT="$HOME/.poetry"
# export PATH="$POETRY_ROOT/bin:$PATH"

# Go setup
# export GOROOT=/usr/local/go
# export PATH="$GOROOT/bin:$PATH"
# export GOPATH=/home/brian/go
# export PATH="$GOPATH/bin:$PATH"

# local bin
export PATH="$HOME/.local/bin:$PATH"

# NVM setup
# export NVM_DIR="$HOME/.nvm"
# [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
# [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# C++
export CMAKE_GENERATOR="Ninja"
export CONAN_CMAKE_GENERATOR="Ninja"
export VCPKG_ROOT="$HOME/tools/vcpkg"
export PATH="$VCPKG_ROOT:$PATH"

if [ -f $VCPKG_ROOT ]; then
  source $VCPKG_ROOT/scripts/vcpkg_completion.zsh
fi

# autoload bashcompinit
# bashcompinit
# source /home/brian/tools/vcpkg/scripts/vcpkg_completion.zsh
