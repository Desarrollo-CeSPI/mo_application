# Cookbook: mo_application-cookbook

Este cookbook es más bien una librería que una receta. La idea es prestar
funcionalidad a recetas como:

* mo_application_php
* mo_application_ruby

Que son especializaciones de esta receta para los lenguajes mencionados.

## Plataformas soportadas

Seguro funciona en Ubuntu y Debian. Debería probarse con la flia Redhat/CentOS

## Atributos

```
default['mo_application']['packages']=[]
default['mo_application']['server_names']=[]
default['mo_application']['ssh_wrapper'] = '/usr/bin/ssh_wrapper'
default['mo_application']['ssh_keys'] = []
default['mo_application']['testing_base_path'] = '/opt/applications'

default['mo_application']['deployment_databag'] = "encrypted_keys"
default['mo_application']['ssh_private_key_databag_item'] = "deploy_key"


default['mo_application']['backup']['database']['mysql']['username'] = 'backup'
default['mo_application']['backup']['database']['mysql']['password'] = 'backup_pass'
default['mo_application']['backup']['database']['mysql']['additional_options'] = ["--single-transaction", "--flush-logs", "--master-data=2", "--quick"]

default['mo_application']['backup']['user'] = "root"
default['mo_application']['backup']['group'] = "root"

default['mo_application']['backup']['ssh_key']['databag'] = "encrypted_keys"
default['mo_application']['backup']['ssh_key']['id'] = "backup_user"


# Data bags used for backups. They must be encrypted
default['mo_application']['backup']['storages_databag'] = "backup_storages"
default['mo_application']['backup']['syncers_databag'] = "backup_syncers"
default['mo_application']['backup']['notifiers_databag'] = "backup_notifiers"

# Array of backup storages databag items within node[mo_application][backup][storages_databag] databaga
default['mo_application']['backup']['storages'] = []
# Array of backup syncers databag items within node[mo_application][backup][syncers_databag] databaga
default['mo_application']['backup']['syncers'] = []
# Array of backup notifiers databag items within node[mo_application][backup][notifiers_databag] databaga
default['mo_application']['backup']['notifiers'] = []
```

### Qué es cada atributo

* **packages**: paquetes extra a instalar
* **server_names**: arreglo de los virtual hosts o aplicaciones que servimos en
  este nodo. A medida que se van configurando aplicaciones en el nodo, se va
  cargando automáticamente este arreglo.
* **ssh_wrapper**: wrapper de ssh para evitar los controles de *StrictHostKeyChecking*
* **ssh_keys**: las claves indicadas aquí podrán conectarse con el usuario de
  cualquier aplicacion deployada usando esta receta
* **testing_base_path**: path base donde se instalarán las aplicaciones. Por
  defecto es `/opt/applications`
* **deployment_databag**: nombre del data bag donde se guardará la clave privada
  (encriptada) del usuario con el que se realiza el deploy
* **ssh_private_key_databag_item**: nombre del data bag item donde está la clave
  privada del usuario con el que se realiza el deploy

* **backup database mysql username**: usuario con el que se realizarán los
  backups. No es posible usar el mismo usuario de la aplicación porque se
  necesita privilegio de **reload** 
* **backup database mysql password**: password del usuario con el que se reaizan
  los backups
* **backup database mysql additional_options**: opciones adicionales para la realización de backups en mysql. Por defecto se flushean los nimary logs, esto es `--single-transaction --flush-logs --master-data=2 --quick`
* **backup user**: usuario que correrá los backups. Por defecto root
* **backup group**: grupo con el que se correrán los backups. Por defecto root
* **backup ssh_key databag**: nombre del databag para buscar la clave ssh para
  conectarse por rsync a servidores usando ssh
* **backup ssh_key id**: nombre del data bag item donde estará la clave privada
  ssh encriptada
* **backup storages_databag**: nombre del databag donde se
  almacenará en items encriptados, información sobre los storages
* **backup syncers_databag**: nombre del databag donde se
  almacenará en items encriptados, información sobre los syncers
* **backup notifiers_databag**: nombre del databag donde se
  almacenará en items encriptados, información sobre los notifiers
* **backup storages**: arreglo con los nombres de los data bag
  items a considerar como storages para backup
* **backup syncers**: arreglo con los nombres de los data bag items
  a considerar como syncers para backup
* **backup notifiers**: arreglo con los nombres de los data bag
  items a considerar como notifiers para backups

### Formato del databag de backup.ssh_key_id y ssh_private_key_databag_item

Es un data bag encriptado con la siguiente estructura

```
{
  "id": "backup_user",
  "default": {
    "ssh_private_key": "-----BEGIN RSA PRIVATE KEY-----1234-----END RSA PRIVATE KEY-----\n",
    "ssh_public_key": "ssh-rsa 1234 user@domain"
  }
}

```

Podría haber un par de claves para cada ambiente. Cuando se cargan las claves en
default, entonces sirve para cualquier ambiente

### Formato del data bag de backup storage, syncer o notifier

Estos data bags deben tener la info que considera la receta **mo_backup**

## Uso

### mo_application::backup

Agrega la clave privada del usuario con el que se realizarán los backups con
syncers 

### mo_application::install

Prepara un sistema que alojará aplicaciones. Para ello instala el ssh_wrapper,
nginx, msttcorefonts para disponer de fuentes que son necesarias cuando se
generan PDFs o documentos que requieren fuentes, prepara el usuario para
realizar los backups con su clave privada para poder realizar las
sincrinizaciones, instala un cliente de mysql y cualquier paquete indicado como
atributo

### mo_application::ssh_wrapper

Instala el wrapper de ssh en el sistema

## Recursos

### mo_application_database

Crea o elimina el usuario en la base de datos para alguna aplicación. Además crea la base
de datos para la aplicacion con perimsos para este usuario en esa db.

#### Acciones

* create
* remove

#### Atributos

* **superuser**: usuario con privilegios para crear usuarios y bases de datos.
  Por defecto es root
* **superuser_password**: password del superusuario. Si no se setea se asume
  `node.mysql.server_root_password`
* **superuser_host**: host donde está la base de datos. Por defecto es localhost
* **name**: nombre de la db a crear
* **application_servers**: arreglo de hosts desde donde se conectarán a la db
* **username**: nombre del usuario. Por defecto se setea a name
* **password**: contraseña para el usuario

### mo_application_user

Crea o elimina el usuario con el que correrá la aplicación. Setea entre otras
cosas, las claves ssh públicas que están autorizadas a conectarse por ssh como
este usuario

### Acciones

* create
* remove

#### Atributos

* **user**: nombre del usuario
* **group**: nombre del grupo del usuario. Si se omite, se asume user
* **home**: si se omite, se asume /home/user
* **shell**: shell a usar. Si se omite se asume /bin/bash
* **ssh_keys**: arreglo de claves públicas

## Mixins

### MoApplication::DeployResourceBase y MoApplication::DeployProviderBase

Representan la funcionalidad del no existente `mo_application_deploy`. Este
mixin es empleado por las recetas mo_application_php y mo_application_ruby
Este recurso funciona de forma similar a como lo hacec capistrano, creando en
donde se deploye la aplicación, tres directorios:

* current
* revisions
* shared

Además de deployar la aplicación, este recurso considera:

* Configurar la rotacion de logs
* Configurar nginx
* Configurar los servicios necesarios (upstart para por ejemplo aplicaciones
  ruby)
* Configurar .my.cnf
* Configurar dotenv como lo entiende **foreman**
* Crea en el home del usuario links a la aplicación y logs

### Atributos

* **home**: home del usuario con el que se deployará la app
* **shell**: shell del usuario
* **ssh_keys: arreglo de claves con las que se podrá hacer ssh a este usuario
* **path**: path donde se instalará la aplicación
* **name**: nombre de la aplicación a deployar
* **deploy**: booleano que indica si hay que hacer un git pull o no. No se usa
  deploy para el server de testing por ejemplo
* **user**: usuario con el que correrá la aplicación
* **group**: grupo con el que correrá la aplicación
* **relative_path**: path relativo a **path**. Por defecto es *app*, por lo que
  la aplicación se deployará en `path/relative_path`
* **repo**: URL del repositorio de donde deployar
* **revision**: revisión, branch o tag a descargar
* **migrate**: correr las migraciones luego del deploy?. Por defecto sí
* **migration_command**: comando a correr como migracion
* **shared_dirs**: hash de directorios que se comparten entre versiones
  deployadas. Ver recurso deploy de chef
* **shared_files**: hash de archivos que se comparten entre versiones
  deployadas. Ver recurso deploy de chef
* **create_dirs_before_symlink**: directorios a crear antes de hacer los
  symlkinks. Ver recurso deploy de chef
* **force_deploy**: forzar un redeploy incluso cuando es la misma revision?
* **ssh_wrapper**: usar un wrapper de ssh? Sí, la idea es usar el que instala
  esta misma receta
* **ssh_private_key**: clave privada del usuario que realiza el deploy.
  Necesario para repositorios privados
* **environment**: hash con variables de ambiente a setear
* **before_migrate**: callback (Proc) de qué hacer antes de correr la migración
* **before_restart**: callback (Proc) de qué hacer antes de restartear la
  aplicación
* **restart_command**: comando para reiniciar la aplicación
* **before_symlink**: callback (Proc) de qué hacer antes de crear los symlinks
* **before_deploy**: callback (Proc) de qué hacer antes de deployar
* **services**: hash de qué servicios se brindan: la clave es el nombre del
  servicio, el valor es el comando para iniciarlo
* **log_dir**: directorio de logs de la aplicación. Si no se setea se asume
  *log*
* **nginx_config**: es un hash donde la clave es el nombre del virtual host de
  nginx. Los valores son un hash de opciones como las entiende nginx_conf. La
  mayor parte de las configuraciones de nginx pueden setearse acá. Se agrega
  únicamente la opción: **relative_document_root** que permite especificar a
  partir de donde se *deployó la aplicación / current*, qué directorio es el
  document_root
* **dotenv**: un hash de variables que permiten setear un archivo shared/.env
  con variables de entorno. Útil para la combinación con **foreman**


## Authors

* Author:: Christian Rodriguez (chrodriguez@gmail.com)
* Author:: Leandro Di Tommaso (leandro.ditommaso@mikroways.net)
