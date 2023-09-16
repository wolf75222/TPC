#!/bin/bash

# Détecte le chemin actuel
CURRENT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# 1. Rendre le script exécutable
chmod +x $CURRENT_PATH/src/tpc.sh

# 2. Ajouter le script à votre PATH dans ~/.bashrc ou ~/.zshrc
echo "export PATH=\$PATH:$CURRENT_PATH" >> ~/.bashrc
# Décommentez la ligne suivante si vous utilisez zsh:
# echo "export PATH=\$PATH:$CURRENT_PATH" >> ~/.zshrc

# 3. Créer un alias pour le script
echo "alias tpc='$CURRENT_PATH/src/tpc.sh'" >> ~/.bashrc
# Décommentez la ligne suivante si vous utilisez zsh:
# echo "alias tpc='$CURRENT_PATH/tpc.sh'" >> ~/.zshrc

# 4. Recharger le fichier de configuration source
source ~/.bashrc
# Décommentez la ligne suivante si vous utilisez zsh:
# source ~/.zshrc

# 5. Configurer le .env
$CURRENT_PATH/src/tpc.sh -c

echo "Configuration terminée avec succès!"
