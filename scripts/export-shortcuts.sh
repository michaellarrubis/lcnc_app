#!/bin/bash

export_shortcuts() {
  local shortcuts="
alias gen_migrate=\"bash $PWD/scripts/migrate.sh\"
alias gen_migrate_seed=\"bash $PWD/scripts/migrate-seed.sh\"

alias gen_app=\"bash $PWD/scripts/generate/main.sh\"

alias gen_api=\"bash $PWD/scripts/generate/api/exec.sh\"

alias gen_api_migration=\"bash $PWD/scripts/generate/api/migration/index.sh\"
alias gen_api_interface=\"bash $PWD/scripts/generate/api/interface.sh\"
alias gen_api_swagger=\"bash $PWD/scripts/generate/api/swagger.sh\"
alias gen_api_route=\"bash $PWD/scripts/generate/api/route.sh\"
alias gen_api_service=\"bash $PWD/scripts/generate/api/service.sh\"

alias gen_client=\"bash $PWD/scripts/generate/client/exec.sh\"
alias gen_client_api=\"bash $PWD/scripts/generate/client/setup-api.sh\"
alias gen_client_redux=\"bash $PWD/scripts/generate/client/setup-redux/index.sh\"
alias gen_client_hooks=\"bash $PWD/scripts/generate/client/setup-hooks/index.sh\"
alias gen_client_page=\"bash $PWD/scripts/generate/client/setup-page/index.sh\"
"

  if [ -f "$HOME/.zshrc" ]; then
    echo "Exporting shortcuts to .zshrc..."
    echo "$shortcuts" >> "$HOME/.zshrc"
    echo "Shortcuts exported to .zshrc successfully!"
  elif [ -f "$HOME/.bashrc" ]; then
    echo "Exporting shortcuts to .bashrc..."
    echo "$shortcuts" >> "$HOME/.bashrc"
    echo "Shortcuts exported to .bashrc successfully!"
  else
    echo "Error: Neither .zshrc nor .bashrc found. Please create one of them and run the script again."
    exit 1
  fi
}

# Run the export_shortcuts function
export_shortcuts
