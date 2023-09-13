# TPC

Ce script Bash permet de compiler, exécuter, et gérer des programmes C en simplifiant les opérations de développement typiques. Il prend en charge diverses options pour offrir une flexibilité maximale.

![alt text](https://github.com/wolf75222/TPC/blob/main/assets/demo.png)


## Prérequis

- Bash 4.0 ou supérieur
- GCC (GNU Compiler Collection)
- zip (pour l'archivage)

## Fonctionnalités

- Compile un programme C en fonction des numéros de TP, d'exercice, et de question
- Exécute le programme compilé
- Supprime le fichier compilé après exécution
- Ouvre le fichier compilé (sur les systèmes qui supportent la commande `open`)
- Logging des actions dans un fichier
- Vérification de la syntaxe
- Mode debug pour la compilation
- Mode silencieux
- Exécution sans compilation (utilise l'exécutable existant)
- Liste tous les fichiers C dans le répertoire de base
- Nettoie les fichiers objets et temporaires
- Optimise la compilation avec `gcc -O2`
- Archive le TP en fichier zip

## Utilisation

Syntaxe de base:

```bash
./cc.sh <num_tp> <num_exo> <num_question> [options]
```

Options disponibles:

```
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
```

## Exemples

- Pour compiler et exécuter le TP 1, Exercice 2, Question 3 :

```bash
./cc.sh 1 2 3
```

- Pour vérifier la syntaxe sans compilation :

```bash
./cc.sh 1 2 3 -v
```

- Pour activer le logging :

```bash
./cc.sh 1 2 3 -l
```

- Pour archiver le TP 1 :

```bash
./cc.sh -a 1
```

## Notes

- Assurez-vous que les répertoires spécifiés dans `BASE_DIR` et `LOG_DIR` existent et sont accessibles.
- La commande `open` est spécifique aux systèmes qui la supportent, comme macOS.

## 1. Rendre le script exécutable :

Si ce n'est pas déjà fait, rendez le script exécutable en utilisant `chmod`:

```bash
chmod +x /chemin/vers/votre/cc.sh
```

Remplacez `/chemin/vers/votre/` par le chemin réel vers votre script.

## 2. Ajouter le script à votre `PATH`

Vous avez deux choix ici:

### a. Ajouter tout le répertoire au `PATH` :

Si vous avez plusieurs scripts dans le même répertoire et que vous voulez tous les rendre accessibles, ajoutez le répertoire à votre `PATH`.

#### Pour Bash:

Ouvrez votre fichier `~/.bashrc`:

```bash
nano ~/.bashrc
```

Ajoutez cette ligne à la fin :

```bash
export PATH="$PATH:/chemin/vers/votre/répertoire"
```

#### Pour Zsh:

Ouvrez votre fichier `~/.zshrc`:

```bash
nano ~/.zshrc
```

Ajoutez cette ligne à la fin :

```bash
export PATH="$PATH:/chemin/vers/votre/répertoire"
```

### b. Créer un alias pour le script:

Si vous ne voulez pas ajouter tout le répertoire à votre `PATH`, vous pouvez simplement créer un alias pour le script.

#### Pour Bash:

Dans `~/.bashrc`:

```bash
alias tpc="/chemin/vers/votre/cc.sh"
```

Remplacez `nomcommande` par le nom que vous voulez utiliser pour votre commande.

#### Pour Zsh:

Dans `~/.zshrc`:

```bash
alias tpc="/chemin/vers/votre/cc.sh"
```

## 3. Recharger le fichier de configuration

Après avoir ajouté le répertoire à votre `PATH` ou créé un alias pour votre script, rechargez le fichier de configuration pour que les changements prennent effet.

#### Pour Bash:

```bash
source ~/.bashrc
```

#### Pour Zsh:

```bash
source ~/.zshrc
```

Maintenant, vous devriez pouvoir exécuter votre script comme une commande en utilisant son nom (ou l'alias que vous avez défini) de n'importe où dans votre terminal.

## Licence

Ce script est distribué sous la licence MIT. Vous êtes libre de l'utiliser, de le modifier et de le redistribuer.
