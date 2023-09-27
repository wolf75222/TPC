# TPC

Ce script Bash permet de compiler, exécuter, et gérer des programmes C en simplifiant les opérations de développement typiques. Il prend en charge diverses options pour offrir une flexibilité maximale.

![alt text](https://github.com/wolf75222/TPC/blob/main/assets/demo.png)


## Prérequis

- Bash 4.0 ou supérieur
- GCC (GNU Compiler Collection)
- zip (pour l'archivage)
- tar (pour l'archivage)
- PowerShell (pour Windows)
- gedit (pour l'ouverture de fichiers)
- nano (pour l'ouverture de fichiers)

## Arborescence des TP

Afin d'assurer une organisation correcte des travaux pratiques (TP), il est essentiel de suivre l'arborescence suivante :

```
.
├── TP1                          # Dossier pour le TP numéro 1
│   ├── Exo1                     # Dossier pour le premier exercice du TP1
│   │   ├── Exo1_Q1.c            # Fichier C pour la première question de l'exercice 1
│   │   ├── Exo1_Q2.c            # Fichier C pour la deuxième question de l'exercice 1
│   │   └── ...
│   ├── Exo2
│   │   ├── Exo2_Q1.c
│   │   └── ...
│   └── ...
├── TP2
│   ├── Exo1
│   │   ├── Exo1_Q1.c
│   │   └── ...
│   └── ...
└── ...
```

- **TPX** : Dossier principal pour chaque TP où `X` est le numéro du TP.
- **ExoY** : Sous-dossier pour chaque exercice du TP où `Y` est le numéro de l'exercice.
- **ExoY_QZ.c** : Fichier C pour chaque question de l'exercice où `Z` est le numéro de la question.

Veuillez suivre cette structure pour chaque nouveau TP afin de garantir une cohérence et une lisibilité optimale de vos travaux.


## Fonctionnalités

- **Créer la structure de TP à partir d'un PDF** : `tpc -p <fichier.pdf>`

- **Configuration des variables d'environnement** : `tpc -c`
  
- **Compilation et exécution** : Compile et exécute le fichier C spécifié.
  
- **Suppression du fichier compilé** : `tpc -r`
  
- **Ouverture du fichier** : Ouvre le fichier spécifié avec `gedit` : `tpc -o`
  
- **Affichage de l'aide** : Montre une liste des options disponibles et comment les utiliser : `tpc -h`
  
- **Activation de la journalisation** : Journalise toutes les actions effectuées : `tpc -l`
  
- **Vérification de la syntaxe** : Vérifie la syntaxe du fichier C spécifié : `tpc -v`
  
- **Mode Debug** : Compile le fichier en mode debug : `tpc -d`
  
- **Mode silencieux** : Exécute le script en mode silencieux : `tpc -s`
  
- **Exécution sans compilation** : Si un fichier déjà compilé existe, l'exécute directement : `tpc -x`
  
- **Liste des fichiers C** : Montre une liste de tous les fichiers C dans le répertoire de base : `tpc -L`
  
- **Suppression des fichiers temporaires** : Supprime les fichiers objets et temporaires du TP spécifié : `tpc -n`
  
- **Optimisation** : Active l'optimisation de la compilation : `tpc -O`
  
- **Archivage** : Archive le TP spécifié : `tpc -a`
  
- **Extraction d'archive dans le dossier courant** : `tpc -e`
  
- **Création de la structure de TP** : Crée la structure du TP avec des fichiers C dans le dossier spécifié : `tpc -f`
  
- **Ajout d'un modèle de fichier** : Ajoute un modèle à un fichier C existant ou crée un fichier C avec un modèle : `tpc -t`

## Exemples d'utilisation

0. **Créer la structure de TP à partir d'un PDF**:
    ```bash
    tpc -p sujet_TP1.pdf  # Crée la structure pour le TP1 à partir du PDF
    ```

1. **Compiler et exécuter un fichier spécifique** :
    ```bash
    tpc 1 1 1   # Compile et exécute Exo1_Q1.c du TP1
    tpc first.c # Compile et exécute first.c
    ```

2. **Archivage** :
    ```bash
    tpc -a 1 zip               # Archive le TP1 au format zip
    tpc -a /path/to/dir tar.gz # Archive le dossier spécifié au format tar.gz
    ```

3. **Ouvrir un fichier avec `gedit`** :
    ```bash
    tpc -o 1 2 1  # Ouvre Exo2_Q1.c du TP1 avec gedit
    ```

4. **Exécution sans compilation** :
    ```bash
    tpc -x 1 2 1  # Exécute le fichier compilé Exo2_Q1.c du TP1
    ```

5. **Afficher la liste des fichiers C** :
    ```bash
    tpc -L  # Affiche la liste des fichiers .c dans le répertoire de base
    ```

6. **Supprimer les fichiers temporaires** :
    ```bash
    tpc -n 1  # Supprime les fichiers objets/temporaires du TP1
    ```

7. **Créer la structure de TP** :
    ```bash
    tpc -f /path/to/dir  # Crée la structure de TP dans le dossier spécifié
    ```

8. **Ajouter un modèle à un fichier C** :
    ```bash
    tpc -t /path/to/file  # Ajoute un modèle de fichier
    ```

Et bien plus encore...


## Notes

- Assurez-vous que les répertoires spécifiés dans `BASE_DIR` et `LOG_DIR` existent et sont accessibles.
- Le script ne fonctionne que pour les fichiers C (`.c`).
- Le script ne fonctionne que pour les systèmes UNIX (Linux, macOS, etc.) et Windows (via PowerShell).

## Configuration

Avant de démarrer, veuillez configurer les variables d'environnement nécessaires. Créez un fichier `.env` à la racine du projet et spécifiez les valeurs suivantes :

```env
# Chemin vers le dossier contenant les fichiers C
BASE_DIR=/chemin/vers/vos/fichiers
# Chemin vers les Logs
LOG_DIR=/chemin/vers/vos/logs
# Type OS : UNIX, WIN
OS=UNIX
# Auteur du TP
AUTHOR=Despoullains Romain

```

### 1. Rendre le script exécutable :

Pour rendre le script exécutable :

```bash
chmod +x setup.sh
```

### 2. Configuration automatique:

Après avoir cloné le dépôt:

1. Naviguez vers le dossier du dépôt:
```bash
cd TPC
```

2. Exécutez le script de configuration:
```bash
./setup.sh
```

### 3. Configuration manuelle:

#### a. Ajouter le script à votre `PATH`:

##### Pour Bash:

Ouvrez votre fichier `~/.bashrc`:

```bash
nano ~/.bashrc
```

Ajoutez cette ligne à la fin:

```bash
export PATH="$PATH:/chemin/vers/votre/répertoire"
```

##### Pour Zsh:

Ouvrez votre fichier `~/.zshrc`:

```bash
nano ~/.zshrc
```

Ajoutez cette ligne à la fin:

```bash
export PATH="$PATH:/chemin/vers/votre/répertoire"
```

#### b. Créer un alias pour le script:

##### Pour Bash:

Dans `~/.bashrc`:

```bash
alias tpc="/chemin/vers/votre/tpc.sh"
```

##### Pour Zsh:

Dans `~/.zshrc`:

```bash
alias tpc="/chemin/vers/votre/tpc.sh"
```

### 4. Recharger le fichier de configuration:

#### Pour Bash:

```bash
source ~/.bashrc
```

#### Pour Zsh:

```bash
source ~/.zshrc
```
## Configuration pour Windows Terminal

### 1. **PowerShell (`profile.ps1`)**

1. Ouvrez **PowerShell** en tant qu'administrateur.
   
2. Vérifiez l'emplacement de votre fichier `profile.ps1` avec la commande :
   ```powershell
   $PROFILE
   ```

3. Si le fichier n'existe pas, créez-le :
   ```powershell
   New-Item -Type File -Path $PROFILE -Force
   ```

4. Ouvrez ce fichier avec un éditeur (par exemple `notepad`) :
   ```powershell
   notepad $PROFILE
   ```

5. Ajoutez les lignes suivantes :
   ```powershell
   $env:PATH = "$env:PATH;C:\chemin\vers\votre\repertoire"
   Set-Alias -Name tpc -Value "C:\chemin\vers\votre\cc.sh"
   ```

6. Sauvegardez et fermez le fichier.

7. Pour que les modifications prennent effet, fermez et rouvrez **PowerShell**.

### 2. **Variables d'environnement globales (Propriétés système)**

1. Cliquez droit sur le bouton "Démarrer" ou appuyez sur la touche **Windows + X**, puis choisissez "Système".

2. Sélectionnez "Paramètres système avancés" sur le côté gauche.

3. Cliquez sur "Variables d'environnement" en bas à droite.

4. Sous "Variables utilisateur", recherchez la variable `Path` et cliquez sur "Modifier". 

5. Ajoutez `C:\chemin\vers\votre\repertoire` à la fin de la liste des valeurs. Assurez-vous qu'il y a un point-virgule (`;`) séparant chaque entrée.

6. Cliquez sur "OK" pour fermer chaque fenêtre.


**Note**: L'ajout d'alias est plus simple via la première méthode (`profile.ps1` avec PowerShell).


Maintenant, vous devriez pouvoir exécuter votre script comme une commande en utilisant son nom (ou l'alias que vous avez défini) de n'importe où dans votre terminal.


## Licence

Ce script est distribué sous la licence MIT. Vous êtes libre de l'utiliser, de le modifier et de le redistribuer.
