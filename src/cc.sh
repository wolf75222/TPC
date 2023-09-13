#!/bin/bash


# Chemin absolu vers le script courant
SCRIPT_DIR="$(dirname "$(realpath "$0")")"

# Charger les variables d'environnement depuis .env situé à la racine
if [ -f "$SCRIPT_DIR/../.env" ]; then
    while read -r line; do
        # Ignorer les commentaires
        [[ $line =~ ^#.*$ ]] && continue
        # Exporter la variable s'il y a quelque chose à exporter
        [ -n "$line" ] && export "$line"
    done < "$SCRIPT_DIR/../.env"
else
    echo ".env n'existe pas"
    [ $LOGGING -eq 1 ] && log_message "Le fichier .env n'existe pas"
    exit 1
fi

# Vérification de l'existence du dossier
if [ ! -d $BASE_DIR ]; then
    echo "Le dossier $BASE_DIR n'existe pas"
    [ $LOGGING -eq 1 ] && log_message "Le dossier $BASE_DIR n'existe pas"
    exit 1
fi

# Vérification de l'existence du dossier 
if [ ! -d $LOG_DIR ]; then
    echo "Le fichier $LOG_DIR n'existe pas"
    [ $LOGGING -eq 1 ] && log_message "Le fichier $LOG_DIR n'existe pas"
    exit 1
fi
    
# Vérification de l'existence de la variable d'environnement, spécifiant l'os (UNIX ou WIN)
if [ ! -d $OS ]; then
    echo "la variable d'environnement, spécifiant l'os (UNIX ou WIN) n'existe pas ou n'est pas valide"
    [ $LOGGING -eq 1 ] && log_message "la variable d'environnement, spécifiant l'os (UNIX ou WIN) n'existe pas ou n'est pas valide"
    exit 1
fi

# Variables pour les options
REMOVE_COMPILED=0
OPEN_COMPILED=0
SHOW_HELP=0
LOGGING=0
CHECK_SYNTAX=0
DEBUG_MODE=0
SILENT_MODE=0
EXEC_ONLY=0
LIST_FILES=0
CLEAN_UP=0
OPTIMIZE=0
ARCHIVE=0


# Fonction de journalisation selon l'os
log_message() {
    local message=$1
    if [ WIN -e $OS ]; then
        local log_file="${LOG_DIR}\compilation.txt"
    else
        local log_file="${LOG_DIR}/compilation.txt"
    fi
    echo "$(date): $message" >> $log_file
}

# Affiche un message si le mode silencieux n'est pas actif
output_message() {
    if [ $SILENT_MODE -eq 0 ]; then
        echo $1
    fi
    [ $LOGGING -eq 1 ] && log_message "$1"
}

# Traitement des options
while getopts "cohlvdxLnOsa" opt; do
    case $opt in
        a) ARCHIVE=1;;
        c) REMOVE_COMPILED=1;;
        o) OPEN_COMPILED=1;;
        h) SHOW_HELP=1;;
        l) LOGGING=1;;
        v) CHECK_SYNTAX=1;;
        d) DEBUG_MODE=1;;
        s) SILENT_MODE=1;;
        x) EXEC_ONLY=1;;
        L) LIST_FILES=1;;
        n) CLEAN_UP=1;;
        O) OPTIMIZE=1;;
        *) echo "Usage: $0 <num_tp> <num_exo> <num_question> [options]"; exit 1;;
    esac
done

# Affichage de l'aide
if [ $SHOW_HELP -eq 1 ]; then
    cat <<-EOM
Usage: $0 <num_tp> <num_exo> <num_question> [options]
Compile et exécute le fichier C correspondant aux arguments fournis

Arguments:
  <num_tp>        Numéro du TP
  <num_exo>       Numéro de l'exercice
  <num_question>  Numéro de la question

Options:
  -c  Supprime le fichier compilé
  -o  Ouvre le fichier compilé
  -h  Affiche l'aide
  -l  Active le logging
  -v  Vérifie la syntaxe du fichier C
  -d  Active le mode debug
  -s  Mode silencieux
  -x  Exécute sans compilation
  -L  Liste tous les fichiers .c
  -n  Nettoie les fichiers objets ou temporaires
  -O  Optimise la compilation (gcc -O2)
  -a  Archive le TP
EOM
    exit 0
fi

# Listez tous les fichiers .c
if [ $LIST_FILES -eq 1 ]; then
    find $BASE_DIR -name '*.c' | while read -r file; do
        output_message $file 
        [ $LOGGING -eq 1 ] && log_message "affiché : $file"
    done
    exit 0
fi

# Supprimez tous les fichiers objets ou temporaires
if [ $CLEAN_UP -eq 1 ]; then
    FILE_FOUND=0

    find $BASE_DIR -name '*.o' | while read -r file; do
        rm $file
        output_message "Supprimé : $file"
        [ $LOGGING -eq 1 ] && log_message "supprimé : $file"
        FILE_FOUND=1

    done

    if [ $FILE_FOUND -eq 0 ]; then
        output_message "Aucun fichier objet ou temporaire trouvé pour suppression."
        [ $LOGGING -eq 1 ] && log_message "Aucun fichier objet ou temporaire trouvé pour suppression."
    fi

    exit 0
fi

if [ $ARCHIVE -eq 1 ]; then
    if [ -z "$2" ]; then  # vérifiez si le numéro du TP est fourni
        output_message "Usage: $0 -a <num_tp> [other options]"
        [ $LOGGING -eq 1 ] && log_message "Usage: $0 -a <num_tp> [other options]"
        exit 1
    fi
    
    num_tp=$2  # le numéro du TP est le premier argument
    archive_name="TP${num_tp}.zip"
    tp_path="TP${num_tp}"
    
    # Sauvegardez le répertoire actuel
    current_dir=$(pwd)

    # Changez pour le répertoire BASE_DIR
    cd $BASE_DIR
    
    if [ ! -d $tp_path ]; then
        output_message "Le dossier TP${num_tp} n'existe pas"
        [ $LOGGING -eq 1 ] && log_message "Le dossier TP${num_tp} n'existe pas"
        # Revenez au répertoire original avant de quitter
        cd $current_dir
        exit 1
    fi
    
    # Créer l'archive
    zip -r $archive_name $tp_path

    # Revenez au répertoire original
    cd $current_dir

    if [ $? -ne 0 ]; then
        output_message "Erreur lors de la création de l'archive $archive_name"
        [ $LOGGING -eq 1 ] && log_message "Erreur lors de la création de l'archive $archive_name"
        exit 2
    else
        output_message "Archive $archive_name créée avec succès dans $BASE_DIR"
        [ $LOGGING -eq 1 ] && log_message "Archive $archive_name créée avec succès dans $BASE_DIR"
        exit 0
    fi
fi



# Décalage des paramètres
shift $((OPTIND-1))

# Vérification des arguments
if [ $ARCHIVE -ne 1 ] && [ $EXEC_ONLY -eq 0 ] && [ $# -ne 3 ]; then
    output_message "Usage: $0 <num_tp> <num_exo> <num_question> [options]"
    exit 1
fi

# Assignation des arguments
num_tp=$1
num_exo=$2
num_question=$3

# Chemin du fichier selon l'os
if [ WIN -e $OS ]; then
    file_path="${BASE_DIR}\TP${num_tp}\Exo${num_exo}\Exo${num_exo}_Q${num_question}.c"
output_name="${BASE_DIR}\TP${num_tp}\Exo${num_exo}\Exo${num_exo}_Q${num_question}"
else 
    file_path="${BASE_DIR}/TP${num_tp}/Exo${num_exo}/Exo${num_exo}_Q${num_question}.c"
    output_name="${BASE_DIR}/TP${num_tp}/Exo${num_exo}/Exo${num_exo}_Q${num_question}"
fi

# Vérification de l'existence du fichier
if [ ! -f $file_path ]; then
    output_message "Le fichier $file_path n'existe pas"
    [ $LOGGING -eq 1 ] && log_message "Le fichier $file_path n'existe pas"
    exit 1
fi

# Vérification de la syntaxe
if [ $CHECK_SYNTAX -eq 1 ]; then
    gcc -fsyntax-only $file_path
    if [ $? -ne 0 ]; then
        output_message "Des erreurs de syntaxe ont été trouvées dans $file_path"
        [ $LOGGING -eq 1 ] && log_message "Des erreurs de syntaxe ont été trouvées dans $file_path"
        exit 2
    else
        output_message "Aucune erreur de syntaxe dans $file_path"
        [ $LOGGING -eq 1 ] && log_message "Aucune erreur de syntaxe dans $file_path"
        exit 0
    fi
fi

# Compilation
if [ $EXEC_ONLY -eq 0 ]; then
    GCC_OPTS="-Wall -Wextra -Wconversion"
    [ $DEBUG_MODE -eq 1 ] && GCC_OPTS+=" -g"
    [ $OPTIMIZE -eq 1 ] && GCC_OPTS+=" -O2"
    gcc $GCC_OPTS $file_path -o $output_name

    if [ $? -ne 0 ]; then
        output_message "Erreur lors de la compilation de $file_path"
        [ $LOGGING -eq 1 ] && log_message "Erreur lors de la compilation de $file_path"
        exit 2
    else
        output_message "Le fichier $file_path a été compilé avec succès"
        [ $LOGGING -eq 1 ] && log_message "Le fichier $file_path a été compilé avec succès"
    fi
fi

# Exécution
$output_name

if [ $? -ne 0 ]; then
    output_message "Erreur lors de l'exécution de $output_name"
    [ $LOGGING -eq 1 ] && log_message "Erreur lors de l'exécution de $output_name"
    exit 3
else
    output_message "Le fichier $output_name a été exécuté avec succès"
    [ $LOGGING -eq 1 ] && log_message "Le fichier $output_name a été exécuté avec succès"
fi

# Suppression du fichier compilé
[ $REMOVE_COMPILED -eq 1 ] && rm $output_name && output_message "Le fichier $output_name a été supprimé" && [ $LOGGING -eq 1 ] && log_message "Le fichier $output_name a été supprimé"

# Ouverture du fichier compilé
[ $OPEN_COMPILED -eq 1 ] && open $output_name && output_message "Le fichier $output_name a été ouvert" && [ $LOGGING -eq 1 ] && log_message "Le fichier $output_name a été ouvert"




exit 0
