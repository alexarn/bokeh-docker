# bokeh-emacs

Je fourni un conteneur archlinux avec emacs et l'outillage nécessaire au dev Bokeh AFI.

Je me base sur la composition docker fournie dans le répertoire /docker du code de Bokeh.

Je nécessite donc que vous ayez au préalable un clone du dépôt Bokeh à l'endroit de votre choix.

Si vous voulez utiliser les facilités fournies par autofocus, je prévois de trouver un clone du dépôt d'autofocus dans ~/autofocus, n'oubliez pas de configurer votre clé d'API redmine.


## compose.sh, pompulilu, pouvoir magique, pompulilu, c'est fantastique

Ce script permet de lancer des commandes docker-compose en combinant mon conteneur avec les conteneurs fournis dans le répertoire /docker du code Bokeh.

Par convention, vous devez d'abord vous placer à la racine d'un clone du code Bokeh puis invoquer le script.

Pour la suite considérons que je suis l'utilisateur devbokeh et que j'ai un clone de bokeh dans ~/unclient/bokeh et un clone de bokeh-docker dans ~/bokeh-docker.


## Démarrer une composition:

```sh
~ cd unclient/bokeh
bash ../../bokeh-docker/bokeh-emacs/compose.sh -p unclient_189056 up --build -d
```

Il est fortement conseiller de spécifier un -p pour éviter des collisions de nom en environnement multi utilisateur.

__NB:__ Sur le serveur funky, le nom par défaut est le login de l'utilisateur courant.

compose.sh détecte si un fichier docker/.env.dev est présent dans le clone Bokeh.

Si ce n'est pas le cas, il en crée un en copiant docker/.env et calcul ensuite:
* WEB_PORT: premier port disponible entre 10000 et 10500
* WEB_HOST: funky.afi-sa.net, vous devrez configurer votre /etc/hosts en accord
* BOKEH_ROOT: racine du code Bokeh, répertoire courant, ce qui nécessite de lancer la commande depuis la racine du code Bokeh
* GROUP\_ID: groupe principal de l'utilisateur courant
* USER\_ID: identifiant de l'utilisateur courant
* USERNAME: login de l'utilisateur courant
* DOCKER\_GROUP\_ID: identifiant du groupe docker

GROUP\_ID, USER\_ID et USERNAME permettrons de creer le même utilisateur dans le conteneur emacs qui bénéficiera donc des permissions adéquates sur les volumes montés. 

De plus la configuration ssh de l'utilisateur courant sera montées dans le répertoire de ce même utilisateur dans le conteneur.

DOCKER\_GROUP\_ID permettra de déclarer un groupe identique dans le conteneur emacs.

Ceci permettra de lancer des commandes docker depuis ce conteneur vers le conteneur php pour exécution de scripts (upgrade\_db, select\_db, autofocus, etc...) et exécution des tests par phpunit.

Si docker/.env.dev existe déjà il est réutilisé.


## Utiliser l'environnement emacs


### Entrer dans le conteneur emacs

Toujours depuis la racine du code Bokeh

```sh
bash ../../bokeh-docker/bokeh-emacs/compose.sh -p unclient_189056 exec -it emacs bash
```

Autrement dit "exécute bash dans le conteneur emacs de la composition unclient\_189056".

Vous devriez avoir un prompt root à l'interieur du conteneur, il faut tout d'abord se loguer sous votre nom d'utilisateur :

```sh
[root@9a76c89632 /]# su - devbokeh
[devbokeh@9a76c89632 ~]$
```

Le répertoire parent du code source bokeh est monté dans le conteneur sous ~/dev.
Mon bokeh se trouvant dans ~/unclient/bokeh sur l'hote, je le retrouve dans ~/dev dans le conteneur:

```sh
[devbokeh@9a76c89632 ~]$ ls dev/
bokeh
```

### Importer une sauvegarde de base de données

Vous pouvez importer une sauvegarde d'une base client avec dump\_db.

```sh
[devbokeh@9a76c89632 ~]$ dump_db unebase
```

### Démarrer emacs

```sh
[devbokeh@9a76c89632 ~]$ TERM=xterm-256color emacs
```

Au premier lancement, emacs s'assurera de télécharger et d'installer les extensions requises ce qui peut prendre un peu de temps (cf. emacs.el).

Pour sélectionner une base précédemment importée, depuis un buffer d'un fichier php dans emacs C-c C-s et saisir le nom de la base.

### Debugger 

Il faut déclarer l'hote et le port de debuggage du point de vue du conteneur php dans le fichier local.php à la racine du code Bokeh

```php
ini_set('xdebug.client_port', '9000'); // port par défaut de geben
ini_set('xdebug.client_host', 'emacs'); // nom du conteneur emacs dans la composition docker
```
