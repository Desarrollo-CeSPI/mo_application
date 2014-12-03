# mo_application-cookbook

LWRP for base application deployment. It provides helpers for creating:
* Directory for application
* Database
* Deployment
* User for application run

## Usage

Just include this recipe as a dependency and use provided LWRPs:

### Resource `mo_application_chroot`

Creates or removes a chrooted directory. Usefull for **php-fpm** chrooted environments only. 
Copied directories can be specified as parameter. Parameters are:

* **path**: base chroot directory
* **copy_files**: files tobe copied to chroot (uses ldd to follow excecutable/library dependencies)
* **actions**: create or remove

### Resource `mo_application_user`

Creates user used to run application as. Parameters and actions can be seen in
`resources/user.rb`

### Resource `mo_application_database`

Creates or removes databases used by application. It wraps database cookbook. Paramters and actions can be seen in
`resources/database.rb`, but we need to explain what are the following
parameters:

* **name:** database name. If user is ommited, name will be used
* **applications_servers:** array of servers from where specified user can connect from

It is also important to say that Mysql imposes a restriction with **user names**
that must be less or equals to 16 characters. **Be careful when no user is
specified and database name is greater than 16 characters length**

### Resource `mo_application_deploy`

Wraps deploy resource but also:

* Creates needed directories for shared environment
* Provides a **callback_before_deploy** block to be specified as custom ruby
  code to allow you to customize any need before deploying
* Calls deploy resource

## Helper `mo_database`

Preferred way to call `mo_application_database`

## License and Authors

* Author:: Christian Rodriguez (chrodriguez@gmail.com)
* Author:: Leandro Di Tommaso (leandro.ditommaso@mikroways.net)
