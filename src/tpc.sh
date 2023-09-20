#!/bin/bash

#################################
# Titre : TP Compiler           #
# Auteur : Despoullains Romain  #
# Date : 16-09-2023             #
# Version : 2.0                 #
#################################


###############################
# Configuration et chargement #
###############################

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

##############################
# Fonctions de vérification  #
##############################

# fonction de vérification de l'existence du dossier
check_dir() {
    local dir=$1
    if [ ! -d $dir ]; then
        echo "Le dossier $dir n'existe pas"
        [ $LOGGING -eq 1 ] && log_message "Le dossier $dir n'existe pas"
        exit 1
    fi
}

# fonction de vérification de l'existence du fichier
check_file() {
    local file=$1
    if [ ! -f $file ]; then
        echo "Le fichier $file n'existe pas"
        [ $LOGGING -eq 1 ] && log_message "Le fichier $file n'existe pas"
        exit 1
    fi
}

# fonction de vérification de l'existence de la variable d'environnement
check_env_var() {
    local var=$1
    if [ ! -n $var ]; then
        echo "la variable d'environnement $var n'existe pas ou n'est pas valide"
        [ $LOGGING -eq 1 ] && log_message "la variable d'environnement $var n'existe pas ou n'est pas valide"
        exit 1
    fi
}

# fonction de vérification du bon nombre d'arguments passés sans les options : Fonction(nombre d'arguments attendus) -> Affichage (tpc [options] <...>)
check_args() {
    local expected_args=$1
    shift
    if [ $# -ne $expected_args ]; then
        echo "Nombre d'arguments invalide"
        [ $LOGGING -eq 1 ] && log_message "Nombre d'arguments invalide"
        exit 1
    fi
}


##############################
# Vérification des paramètres#
##############################

# Vérification de l'existence du dossier
check_env_var $BASE_DIR
check_dir $BASE_DIR


# Vérification de l'existence du dossier 
check_env_var $LOG_DIR
check_dir $LOG_DIR
    
# Vérification de l'existence de la variable d'environnement, spécifiant l'os (UNIX ou WIN)
check_env_var $OS

##############################
# Fonctions de journalisation #
##############################

# Fonction de journalisation selon l'os
log_message() {
    if [ $LOGGING -eq 1 ] && [ WIN = $OS ]; then
        echo "$(date) : $1" >> $LOG_DIR/$LOG_FILE
    elif [ $LOGGING -eq 1 ] && [ UNIX = $OS ]; then
        echo "$(date) : $1" >> $LOG_DIR/$LOG_FILE
    fi
}

##############################
# Définition des variables   #
##############################


# Variables pour les options
READ_FILE=0
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
EVERYWHERE=0
STRUCTURE=0
USE_TEMPLATE=0
CONFIG_ENV=0

##############################
# Variable pour la template  #
##############################

tp_num=0
line_index=0
exo_content=()
current_exo_num=0
count=0
TEMPLATE_FILE=""



##############################
# Fonction d'affichage       #
##############################

# Fonction d'affichage selon la couleur et le mode silencieux : Fonction(chaîne, couleur) -> Affichage
output_message() {
    if [ $SILENT_MODE -eq 0 ]; then
        if [ $2 = "red" ]; then
            echo -e "\033[31m$1\033[0m"
        elif [ $2 = "green" ]; then
            echo -e "\033[32m$1\033[0m"
        elif [ $2 = "blue" ]; then
            echo -e "\033[34m$1\033[0m"
        else
            echo $1
        fi
    fi
}


#################################
# Fonctions de commande         #
#################################

# Fonction d'affichage de l'aide : Fonction() -> Affichage
show_help() {
    cat <<-EOM

    Usage: tpc [options] <num_tp> <num_exo> <num_question> / tpc [options] <fichier>

    Options:
        -c : Configure les variables d'environnement

        -p: créer la structure à partir d'un fichier pdf
        -r : Supprime le fichier compilé
        -o : Ouvre le fichier (gedit)
        -h : Affiche l'aide
        -l : Active la journalisation
        -v : Vérifie la syntaxe du fichier
        -d : Active le mode debug
        -s : Active le mode silencieux
        -x : Exécute le fichier 
        -L : Affiche la liste des fichiers .c
        -n : Supprime les fichiers objets ou temporaires
        -O : Active l'optimisation
        -a : Archive le TP
        -e : Archive le TP dans le dossier courant
        -f : Crée la structure du TP avec les fichiers .c
        -t : Ajoute un modèle de fichier .c ou Crée un fichier .c avec le modèle


    Exemples:
        tpc 1 1 1                   -> Compile et exécute Exo1_Q1.c du TP1
        tpc first.c                 -> Compile et exécute first.c
        tpc -a 1 zip                -> Archive le TP1 au format zip
        tpc -a /path/to/dir tar.gz  -> Archive le dossier spécifié au format tar.gz
        tpc -o 1 2 1                -> Ouvre Exo2_Q1.c du TP1 avec gedit
        tpc -x 1 2 1                -> Exécute le fichier compilé Exo2_Q1.c du TP1
        tpc -L                      -> Affiche la liste des fichiers .c dans le répertoire de base
        tpc -n 1                    -> Supprime les fichiers objets/temporaires du TP1
        tpc -f /path/to/dir         -> Crée la structure de TP dans le dossier spécifié
        tpc -t /path/to/file        -> Ajoute un modèle de fichier
        etc...


EOM
}

# Fonction d'affichage de la liste des fichiers .c : Fonction(dir) -> Affichage
list_files() {
    local dir=$1
    local files=$(find $dir -name "*.c")
    if [ -n "$files" ]; then
        text="Les fichiers trouvés sont : $files"
        output_message "$text" "blue"
        log_message "$text"
    else
        text="Aucun fichier trouvé"
        output_message "$text" "blue"
        log_message "$text"
    fi
}

# Fonction de suppression des fichiers objets ou temporaires : Fonction(dir) -> Affichage
clean_up() {
    local dir=$1
    local files=$(find $dir -name "*.o" -o -name "*.out" -o -name "*.exe")
    if [ -n "$files" ]; then
        rm $files
        text="Les fichiers supprimés sont : $files"
        output_message "$text" "blue"
        log_message "$text"
    else
        text="Aucun fichier trouvé"
        output_message "$text" "blue"
        log_message "$text"
    fi
} 


# Fonction d'archivage du TP, extension .zip ou .tar.gz on archive dans le dir donner le tp ou dossier donner : Fonction(tp, dir, extension) -> Affichage
archive() {
    local tp=$1
    local dir=$2
    local extension=$3
    local tp_name=$(basename $tp)

    if [ -d $dir ]; then
        if [ $extension = "zip" ]; then
            (cd "$(dirname $tp)" && zip -r "$dir/$tp_name.zip" "$tp_name")
            text="L'archive $dir/$tp_name.zip a été créée"
            output_message "$text" "blue"
            log_message "$text"
        elif [ $extension = "tar.gz" ]; then
            tar -czvf "$dir/$tp_name.tar.gz" -C "$(dirname $tp)" "$tp_name"
            text="L'archive $dir/$tp_name.tar.gz a été créée"
            output_message "$text" "blue"
            log_message "$text"
        else
            text="L'extension $extension n'est pas valide"
            output_message "$text" "red"
            log_message "$text"
            exit 1
        fi
    else
        text="Le dossier $dir n'existe pas"
        output_message "$text" "red"
        log_message "$text"
        exit 1
    fi
}





# Fonction de la vérification de la syntaxe du Fichier : Fonction(fichier) -> Affichage
check_syntax() {
    local file=$1
    if [ -f $file ]; then
        gcc -fsyntax-only $file
        if [ $? -ne 0 ]; then
            text="Erreur de syntaxe dans $file"
            output_message "$text" "red"
            log_message "$text"
            exit 2
        else
            text="La syntaxe de $file est correcte"
            output_message "$text" "green"
            log_message "$text"
        fi
    else
        text="Le fichier $file n'existe pas"
        output_message "$text" "red"
        log_message "$text"
        exit 1
    fi
}

# Fonction de compilation du Fichier : Fonction(fichier) -> Affichage
compile_file() {
    local file=$1
    local GCC_OPTS="-Wall -Wextra -Wconversion"
    output_name="${file%.*}"

    [ $DEBUG_MODE -eq 1 ] && GCC_OPTS+=" -g"
    [ $OPTIMIZE -eq 1 ] && GCC_OPTS+=" -O2"

    if [ -f $file ]; then
        output_message "Compilation de $file" "blue"
        gcc $GCC_OPTS $file -o $output_name
        if [ $? -ne 0 ]; then
            text="Erreur lors de la compilation de $file"
            output_message "$text" "red"
            log_message "$text"
            exit 2
        else
            text="Le fichier $file a été compilé avec succès"
            output_message "$text" "green"
            log_message "$text"
        fi
    else
        text="Le fichier $file n'existe pas"
        output_message "$text" "red"
        log_message "$text"
        exit 1
    fi
}

# Fonction d'éxecution du Fichier : Fonction(fichier) -> Affichage
execute_file() {
    local file=$1
    if [ -f $file ]; then
        output_message "Exécution de $file" "blue"
        chmod +x "$file"
        if [[ "$file" == */* ]]; then
            $file
        else
            ./$file
        fi
        if [ $? -ne 0 ]; then
            text="Erreur lors de l'exécution de $file"
            output_message "$text" "red"
            log_message "$text"
            exit 3
        else
            text="Le fichier $file a été exécuté avec succès"
            output_message "$text" "green"
            log_message "$text"
        fi
    else
        text="Le fichier $file n'existe pas"
        output_message "$text" "red"
        log_message "$text"
        exit 1
    fi
}

# Fonction de suppression du Fichier compiler : Fonction(fichier) -> Affichage
remove_compiled() {
    local file=$1
    if [ -f $file ]; then
        rm $file
        text="Le fichier $file a été supprimé"
        output_message "$text" "blue"
        log_message "$text"
    else
        text="Le fichier $file n'existe pas"
        output_message "$text" "red"
        log_message "$text"
        exit 1
    fi
}

# Fonction d'ouverture (gedit) du Fichier : Fonction(fichier) -> Affichage
open_file() {
    local file=$1
    if [ -f $file ]; then
        gedit $file
        text="Le fichier $file a été ouvert"
        output_message "$text" "blue"
        log_message "$text"
    else
        text="Le fichier $file n'existe pas"
        output_message "$text" "red"
        log_message "$text"
        exit 1
    fi
}


create_tp_structure() {
    # Récupérer le dossier de base passé en paramètre
    local base_dir=$1
    text="Le dossier de base est $base_dir"
    output_message "$text" "blue"
    log_message "$text"

    # Demandez à l'utilisateur le numéro du TP
    read -p "Entrez le numéro du TP : " tp_num

    # Créez le dossier du TP
    tp_dir="${base_dir}/TP${tp_num}"
    mkdir -p $tp_dir
    text="Le dossier $tp_dir a été créé"
    output_message "$text" "blue"
    log_message "$text"

    # Demandez à l'utilisateur combien d'exercices sont dans ce TP
    read -p "Combien d'exercices sont dans le TP${tp_num} : " exo_count

    for (( exo_num=1; exo_num<=exo_count; exo_num++ )); do
        exo_dir="${tp_dir}/Exo${exo_num}"
        mkdir -p $exo_dir
        text="Le dossier $exo_dir a été créé"
        output_message "$text" "blue"
        log_message "$text"

        # Demandez à l'utilisateur combien de questions sont dans cet exercice
        read -p "Combien de questions dans Exo${exo_num} : " question_count

        for (( q_num=1; q_num<=question_count; q_num++ )); do
            file_path="${exo_dir}/Exo${exo_num}_Q${q_num}.c"
            
            # Remplacez touch par add_template
            add_template $file_path
            
            text="Le fichier ${file_path} a été créé avec le modèle"
            output_message "$text" "blue"
            log_message "$text"
        done
    done
}

# create_tp_structure_pdf array
create_tp_structure_pdf() {
    # Récupérer le dossier de base passé en paramètre
    local base_dir=$BASE_DIR
     text="Le dossier de base est $base_dir"
    output_message "$text" "blue"
    log_message "$text"

    # Demandez à l'utilisateur le numéro du TP
 
   # Créez le dossier du TP
    tp_dir="${base_dir}/TP${tp_num}"
    if [[ -d $tp_dir ]]; then
        output_message "Le dossier $tp_dir existe déja" "red"
        exit 0
    fi
    mkdir -p $tp_dir
    text="Le dossier $tp_dir a été créé"
    output_message "$text" "blue"
    log_message "$text"

    # Demandez à l'utilisateur combien d'exercices sont dans ce TP
     for (( exo_num=1; exo_num<=${#arr[*]}; exo_num++ )); do
        exo_dir="${tp_dir}/Exo${exo_num}"
        mkdir -p $exo_dir
        text="Le dossier $exo_dir a été créé"
        output_message "$text" "blue"
        log_message "$text"

        # Demandez à l'utilisateur combien de questions sont dans cet exercice
        temp=$exo_num-1
        for (( q_num=1; q_num<=arr[$temp]; q_num++ )); do
            file_path="${exo_dir}/Exo${exo_num}_Q${q_num}.c"
            
            # Remplacez touch par add_template
            add_template $file_path
            
            text="Le fichier ${file_path} a été créé avec le modèle"
            output_message "$text" "blue"
            log_message "$text"
        done
    done
}


# extract_pdf_file file.pdf
# extract_pdf_file(){
    
# }


# Fonction pour ajouter un modèle
add_template() {
    local file_path="$1"

    cat > "$file_path" <<-EOM
/* 
* Nom du fichier: $(basename "$file_path")
* Date: $(date)
* Auteur: [Votre Nom]
* Description: [Description du fichier]
*/

#include <stdio.h>

int main() {
    // Votre code ici

    return 0;
}
EOM

    text="Le modèle $file_path a été créé"
    output_message "$text" "blue"
    log_message "$text"
}

configure_env() {

    # Chemin vers le fichier .env
    ENV_FILE_PATH="$SCRIPT_DIR/../.env"

    # Vérifier si .env existe
    if [[ ! -f $ENV_FILE_PATH ]]; then
        output_message "Le fichier .env n'existe pas" "red"
        log_message "Le fichier .env n'existe pas"
        exit 1
    fi
    # Charger les valeurs actuelles
    source .env

    output_message "Configuration actuelle : " "blue"
    output_message "BASE_DIR : $BASE_DIR" "blue"
    output_message "LOG_DIR : $LOG_DIR" "blue"
    output_message "OS : $OS" "blue"

    # Demander à l'utilisateur s'il souhaite modifier ces valeurs
    read -p "Entrez un nouveau chemin pour BASE_DIR ou appuyez sur Entrée pour conserver l'actuel [$BASE_DIR]: " new_base_dir
    read -p "Entrez un nouveau chemin pour LOG_DIR ou appuyez sur Entrée pour conserver l'actuel [$LOG_DIR]: " new_log_dir
    read -p "Entrez un nouveau type pour OS (UNIX/WIN) ou appuyez sur Entrée pour conserver l'actuel [$OS]: " new_os

    # Utiliser les nouvelles valeurs si elles sont fournies, sinon conserver les anciennes
    [ -z "$new_base_dir" ] || BASE_DIR=$new_base_dir
    [ -z "$new_log_dir" ] || LOG_DIR=$new_log_dir
    [ -z "$new_os" ] || OS=$new_os

    # Écrire les nouvelles valeurs dans .env
    echo "# Chemin vers le dossier contenant les fichiers C" > .env
    echo "BASE_DIR=$BASE_DIR" >> .env
    echo "# Chemin vers les Logs" >> .env
    echo "LOG_DIR=$LOG_DIR" >> .env
    echo "# Type OS : UNIX, WIN" >> .env
    echo "OS=$OS" >> .env

    output_message "Configuration mise à jour avec succès!" "green"
    log_message "Configuration mise à jour avec succès!"
    output_message "Nouvelle configuration : " "blue"
    output_message "BASE_DIR : $BASE_DIR" "blue"
    output_message "LOG_DIR : $LOG_DIR" "blue"
    output_message "OS : $OS" "blue"

}


##############################
# Traitement des options     #
##############################

# Traitement des options
while getopts "rohlvdnsxLOaeftcp" opt; do
    case $opt in

        p)
            READ_FILE=1
            ;;
        r)
            REMOVE_COMPILED=1
            ;;
        o)
            OPEN_COMPILED=1
            ;;
        h)
            SHOW_HELP=1
            ;;
        l)
            LOGGING=1
            ;;
        v)
            CHECK_SYNTAX=1
            ;;
        d)
            DEBUG_MODE=1
            ;;
        s)
            SILENT_MODE=1
            ;;
        x)
            EXEC_ONLY=1
            ;;
        L)
            LIST_FILES=1
            ;;
        n)
            CLEAN_UP=1
            ;;
        O)
            OPTIMIZE=1
            ;;
        a)
            ARCHIVE=1
            ;;
        e)
            EVERYWHERE=1
            ;;
        f) 
            STRUCTURE=1
            ;;
        t)
            USE_TEMPLATE=1
            ;;
        c)
            CONFIG_ENV=1
            ;;
            
        \?)
            echo "Option invalide : -$OPTARG" >&2
            exit 1
            ;;
    esac
done

# Retirer les options 
shift $((OPTIND-1))

##############################
# Corps du script            #
##############################


if [ $READ_FILE -eq 1 ]; then
    check_args 1 "$@"
    check_file $1
    filecontent=$(pdftotext $1 -)
    IFS=$'\n' read -d '' -ra lines <<< "$filecontent"
    for line in "${lines[@]}"; do
        if [[ $line_index -eq 1 ]]; then
            tp_num=$(echo "$line" | tr -dc '0-9')
        fi
        if [[ "$line" == *Exercice* ]]; then
            ((current_exo_num++))  
            exo_content[$current_exo_num]=0
        elif [[ "$line" == *"•"* ]]; then
            ((exo_content[$current_exo_num]++))  
        fi
        ((line_index++))
    done
    create_tp_structure_pdf "${exo_content[@]}"
    exit 0 
fi




# -h
if [ $SHOW_HELP -eq 1 ]; then
    check_args 0 "$@"
    show_help
    exit 0
fi

if [ $CONFIG_ENV -eq 1 ]; then
    check_args 0 "$@"
    configure_env
    exit 0
fi

# tpc -a <num_tp> <extension> ou tpc -a <dir> <extension>
if [ $ARCHIVE -eq 1 ]; then
    check_args 2 "$@"
    dir=$BASE_DIR
    if [ $EVERYWHERE -eq 1 ]; then
        dir=$(pwd)
    fi
    # on vérifie si le premier argument est un nombre
    if [[ $1 =~ ^[0-9]+$ ]]; then
        num_tp=$1
        if [ "WIN" = "$OS" ]; then
            dir_tp="${BASE_DIR}\TP${num_tp}"
        else 
            dir_tp="${BASE_DIR}/TP${num_tp}"
        fi
        archive $dir_tp $dir $2
    else
        archive $1 $dir $2
    fi
    exit 0
fi

# tpc -L <num_tp> ou tpc -L <dir> ou tpc -L
if [ $LIST_FILES -eq 1 ]; then
    if [ $# -eq 0 ]; then
        dir=$BASE_DIR
        if [ $EVERYWHERE -eq 1 ]; then
            dir=$(pwd)
        fi
        list_files $dir
    elif [ $# -eq 1 ]; then
        # on vérifie si le premier argument est un nombre
        if [[ $1 =~ ^[0-9]+$ ]]; then
            num_tp=$1
            if [ "WIN" = "$OS" ]; then
                dir_tp="${BASE_DIR}\TP${num_tp}"
            else 
                dir_tp="${BASE_DIR}/TP${num_tp}"
            fi
            list_files $dir_tp
        else
            list_files $1
        fi
    else
        output_message "Nombre d'arguments invalide" "red"
        exit 1
    fi
    exit 0
fi

# tpc -n <num_tp> ou tpc -n <dir> ou tpc -n
if [ $CLEAN_UP -eq 1 ]; then
    if [ $# -eq 0 ]; then
        dir=$BASE_DIR
        if [ $EVERYWHERE -eq 1 ]; then
            dir=$(pwd)
        fi
        clean_up $dir
    elif [ $# -eq 1 ]; then
        # on vérifie si le premier argument est un nombre
        if [[ $1 =~ ^[0-9]+$ ]]; then
            num_tp=$1
            if [ "WIN" = "$OS" ]; then
                dir_tp="${BASE_DIR}\TP${num_tp}"
            else 
                dir_tp="${BASE_DIR}/TP${num_tp}"
            fi
            clean_up $dir_tp
        else
            clean_up $1
        fi
    else
        output_message "Nombre d'arguments invalide" "red"
        exit 1
    fi
    exit 0
fi

# tpc -v <num_tp> <num_exo> <num_question> ou tpc -v <fichier>
if [ $CHECK_SYNTAX -eq 1 ]; then
    if [ $# -eq 1 ]; then
        check_syntax $1
    elif [ $# -eq 3 ]; then
        # on vérifie si le premier argument est un nombre
        if [[ $1 =~ ^[0-9]+$ ]]; then
            num_tp=$1
            if [ "WIN" = "$OS" ]; then
                dir_tp="${BASE_DIR}\TP${num_tp}"
            else 
                dir_tp="${BASE_DIR}/TP${num_tp}"
            fi
            file_path="${dir_tp}/Exo${2}/Exo${2}_Q${3}.c"
            check_syntax $file_path
        else
            check_syntax $1
        fi
    else
        output_message "Nombre d'arguments invalide" "red"
        exit 1
    fi
    exit 0
fi

# tpc -o <num_tp> <num_exo> <num_question> ou tpc -o <fichier>
if [ $OPEN_COMPILED -eq 1 ]; then
    if [ $# -eq 1 ]; then
        open_file $1
    elif [ $# -eq 3 ]; then
        # on vérifie si le premier argument est un nombre
        if [[ $1 =~ ^[0-9]+$ ]]; then
            num_tp=$1
            if [ "WIN" = "$OS" ]; then
                dir_tp="${BASE_DIR}\TP${num_tp}"
            else 
                dir_tp="${BASE_DIR}/TP${num_tp}"
            fi
            file_path="${dir_tp}/Exo${2}/Exo${2}_Q${3}.c"
            open_file $file_path
        else
            open_file $1
        fi
    else
        output_message "Nombre d'arguments invalide" "red"
        exit 1
    fi
    exit 0
fi

# tpc -x <num_tp> <num_exo> <num_question> ou tpc -x <fichier>
if [ $EXEC_ONLY -eq 1 ]; then
    if [ $# -eq 1 ]; then
        execute_file $1
    elif [ $# -eq 3 ]; then
        # on vérifie si le premier argument est un nombre
        if [[ $1 =~ ^[0-9]+$ ]]; then
            num_tp=$1
            if [ "WIN" = "$OS" ]; then
                dir_tp="${BASE_DIR}\TP${num_tp}"
            else 
                dir_tp="${BASE_DIR}/TP${num_tp}"
            fi
            file_path="${dir_tp}/Exo${2}/Exo${2}_Q${3}.c"
            execute_file "${file_path%.*}"
        else
            execute_file $1
        fi
    else
        output_message "Nombre d'arguments invalide" "red"
        exit 1
    fi
    exit 0
fi


# tpc -f <dir> ou tpc -f
if [ $STRUCTURE -eq 1 ]; then
    if [ $# -eq 0 ]; then
        create_tp_structure $BASE_DIR
    elif [ $# -eq 1 ]; then
        create_tp_structure $1
    else
        output_message "Nombre d'arguments invalide" "red"
        exit 1
    fi
    exit 0
fi

# tpc -t <num_tp> <num_exo> <num_question> ou tpc -t <fichier>
if [ $USE_TEMPLATE -eq 1 ]; then
    if [ $# -eq 1 ]; then
        add_template $1
    elif [ $# -eq 3 ]; then
        # on vérifie si le premier argument est un nombre
        if [[ $1 =~ ^[0-9]+$ ]]; then
            num_tp=$1
            if [ "WIN" = "$OS" ]; then
                dir_tp="${BASE_DIR}\TP${num_tp}"
            else 
                dir_tp="${BASE_DIR}/TP${num_tp}"
            fi
            file_path="${dir_tp}/Exo${2}/Exo${2}_Q${3}.c"
            add_template $file_path
        else
            add_template $1
        fi
    else
        output_message "Nombre d'arguments invalide" "red"
        exit 1
    fi
    exit 0
fi



# tpc <num_tp> <num_exo> <num_question> ou tpc <fichier> 
if [ $# -eq 0 ]; then
    output_message "Usage: tpc [options] <num_tp> <num_exo> <num_question> / tpc [options] <fichier> " "red"
    exit 1

elif [ $# -eq 1 ]; then
    check_args 1 "$@"
    compile_file $1
    execute_file $output_name
    if [ $REMOVE_COMPILED -eq 1 ]; then
        remove_compiled $output_name
    fi
    exit 0

elif [ $# -eq 3 ]; then
    check_args 3 "$@"
    # on vérifie si le premier argument est un nombre
    if [[ $1 =~ ^[0-9]+$ ]]; then
        num_tp=$1
        if [ "WIN" = "$OS" ]; then
            dir_tp="${BASE_DIR}\TP${num_tp}"
        else 
            dir_tp="${BASE_DIR}/TP${num_tp}"
        fi
        file_path="${dir_tp}/Exo${2}/Exo${2}_Q${3}.c"
        compile_file $file_path
        execute_file $output_name
        if [ $REMOVE_COMPILED -eq 1 ]; then
            remove_compiled $output_name
        fi
    else
        compile_file $1
        execute_file $output_name
        if [ $REMOVE_COMPILED -eq 1 ]; then
            remove_compiled $output_name
        fi
    fi
    exit 0
else
    output_message "Nombre d'arguments invalide" "red"
    exit 1
fi

# Suppression du fichier compilé
if [ $REMOVE_COMPILED -eq 1 ]; then
    remove_compiled $output_name
fi



exit 0