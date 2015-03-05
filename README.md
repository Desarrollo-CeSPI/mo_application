# Cookbook: mo_application-cookbook

LWRP for base application deployment. It provides helpers for creating:
* Directory for application
* Database
* Deployment
* User for application run

## Table of Contents

* [Usage](#usage)
  * [Resource mo_application_chroot](#resource-mo_application_chroot)
  * [Resource mo_application_user](#resource-mo_application_user)
  * [Resource mo_application_database](#resource-mo_application_database)
  * [Resource mo_application_deploy](#resource-mo_application_deploy)
* [Helper mo_database](#)
* [License](#license)
* [Authors](#authors)

## Usage

Just include this recipe as a dependency and use provided LWRPs:

### Resource `mo_application_chroot`

Creates or removes a chrooted directory. Usefull for **php-fpm** chrooted environments only. 
Copied directories can be specified as parameter. Parameters are:

* **path**: base chroot directory
* **copy_files**: files tobe copied to chroot (uses ldd to follow excecutable/library dependencies)
* **actions**: create or remove

**IMPORTANT**: there is a bug with the chroot implementation and PHP-FPM which
causes random "File not found" errors.

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

## License

The MIT License (MIT)

Copyright (c) 2014 Christian Rodriguez & Leandro Di Tommaso

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

## Authors

* Author:: Christian Rodriguez (chrodriguez@gmail.com)
* Author:: Leandro Di Tommaso (leandro.ditommaso@mikroways.net)
