if [ -x "$(command -v asdf)" ]; then
  export PATH="${ASDF_DATA_DIR:-$HOME/.asdf}/shims:$PATH"

  # update packages
  asdf_update() {
    if [ $# -eq 0 ]; then
      echo "Usage: You must pass the name of at least one asdf plugin to update"
      echo "Example: asdf_update fzf jq"
      return
    fi

    for plugin in $@; do
      if asdf plugin list | grep -q "$plugin"; then
        echo "Updating: $plugin"

        local current_version="$(asdf current $plugin | grep -oP '\d+\.\d+\.\d+')"
        echo "Upgrading from version: $current_version"

        asdf install $plugin latest
        asdf set -u $plugin latest

        local new_version="$(asdf current $plugin | grep -oP '\d+\.\d+\.\d+')"
        echo "Upgraded to version: $new_version"

        if [[ $new_version = $current_version ]]; then
          echo "No change"
        else
          asdf uninstall $plugin $current_version
          echo "Uninstalling old version"
        fi
      else
        echo "Error: $plugin is not an enabled asdf plugin. If you would like to enable it run 'asdf plugin add $plugin'"
      fi
      echo ""
    done
  }

  asdf_update_all() {
    asdf plugin list | while IFS= read -r line; do
      asdf_update $line
    done
  }
fi
