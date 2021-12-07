# Etherpad module for Puppet

[![Build Status](https://travis-ci.org/voxpupuli/puppet-etherpad.png?branch=master)](https://travis-ci.org/voxpupuli/puppet-etherpad)
[![Code Coverage](https://coveralls.io/repos/github/voxpupuli/puppet-etherpad/badge.svg?branch=master)](https://coveralls.io/github/voxpupuli/puppet-etherpad)
[![Puppet Forge](https://img.shields.io/puppetforge/v/puppet/etherpad.svg)](https://forge.puppetlabs.com/puppet/etherpad)
[![Puppet Forge - downloads](https://img.shields.io/puppetforge/dt/puppet/etherpad.svg)](https://forge.puppetlabs.com/puppet/etherpad)
[![Puppet Forge - endorsement](https://img.shields.io/puppetforge/e/puppet/etherpad.svg)](https://forge.puppetlabs.com/puppet/etherpad)
[![Puppet Forge - scores](https://img.shields.io/puppetforge/f/puppet/etherpad.svg)](https://forge.puppetlabs.com/puppet/etherpad)

#### Table of Contents

1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
3. [Setup - The basics of getting started with etherpad](#setup)
    * [What etherpad affects](#what-etherpad-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with etherpad](#beginning-with-etherpad)
4. [Usage - Configuration options and additional functionality](#usage)
5. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)

## Overview

This module installs and configures etherpad(-lite). It's inspired by existing
etherpad modules on the Forge, but attempts to "*do it right™*".

## Setup

### What etherpad affects

* This module depends on [puppet-nodejs](https://forge.puppetlabs.com/puppet/nodejs)
* It also depends on [puppetlabs-vcsrepo](https://forge.puppetlabs.com/puppetlabs/vcsrepo),
  and hence git
* It will setup a service using the system's preferred init
* When running installDeps.sh, this module requires all the usual build tools,
  development packages and headers as any other (complex) npm install
* When running on ubuntu OS, it will setup apt sources for nodejs with [puppetlabs-apt](https://forge.puppetlabs.com/puppetlabs/apt).

### Setup Requirements

This module requires a database. With no database available, it will use
DirtyDB as fallback. This is not intended for production use.

For a migration from DirtyDB, please consult [this blog post](https://codeborne.com/2011/10/19/etherpad-lite-migrate-data-from-dirtydb.html)

On Ubuntu system, as soft dependency, you will need to ensure that puppetlabs-apt version 4.4.0 or above is installed.

### Beginning with etherpad

Before to installation, a target database should exist. Please consult the
documentation of
[puppetlabs-postgresql](https://forge.puppetlabs.com/puppetlabs/postgresql), or
[puppetlabs-mysql](https://forge.puppetlabs.com/puppetlabs/mysql) for how to
create those.

## Usage

The basic usage is:

```puppet
include ::etherpad
```

note that this will use the local DirtyDB and is not recommended beyond basic testing.
For production setups, use:

```puppet
class { 'etherpad':
  ensure            => 'present',
  database_type     => 'mysql',
  database_name     => 'etherpad',
  database_user     => 'etherpad',
  database_password => '37h3rp4d',
  users             => {
    admin => {
      password => 's3cr3t',
      is_admin => true,
    },
    user  => {
      password => 'secret',
      is_admin => false,
    },
  },
}
```

## Reference

### etherpad

The etherpad module installs and configures etherpad.  This class is the entry
point for the module and the configuration point.

#### ensure

Ensure the presence (`present`, `latest`) or absence (`absent`) of etherpad.
This can also be set to a specific version (or SHA1 hash). By default, we
install from the branch `develop`, in order to cater for newer versions of
Nodejs. `absent` will completely remove the software, its dependencies, and the
users and groups.

|Type|Default|
|----|-------|
| String | `present` |

#### service_name

Name under which the service will be known.

|Type |Default |
|-----|--------|
| String | `etherpad` |

#### service_ensure

Ensure whether the service is running or stopped. If you're passing `absent` to
`ensure`, please also pass `stopped` to `service_ensure`.

|Type |Default |
|-----|--------|
| Enum['running', 'stopped'] | `running` |

#### service_provider

Which [service provider](https://docs.puppetlabs.com/references/latest/type.html#service-providers)
to use. By default this is taken from stdlib's [`$::service_provider`]() fact.
Currently only `upstart` and `systemd` are supported!

|Type |Default |
|-----|--------|
| Optional[String] | `$::service_provider` |

#### manage_user

Whether to manage the user & group under which etherpad will be running.

|Type |Default |
|-----|--------|
|Boolean|`true`|

#### manage_abiword

Whether to manage the dependency of the abiword package.

|Type |Default |
|-----|--------|
|Boolean|`false`|

#### abiword_path

Absolute Path to the abiword binary.

|Type |Default |
|-----|--------|
|String|`/usr/bin/abiword`|

#### manage_tidy

Whether to manage the dependency of the tidy package.

|Type |Default |
|-----|--------|
|Boolean|`false`|

#### abiword_path

Absolute Path to the abiword binary.

|Type |Default |
|-----|--------|
|String|`/usr/bin/abiword`|

#### user & group

The user and group under which etherpad will be running.

|Type |Default |
|-----|--------|
|String|`etherpad`|

#### root_dir

Absolute Path of the etherpad installation.

|Type |Default |
|-----|--------|
|String|`/opt/etherpad`|

#### source

URL to the git source of etherpad.

|Type |Default |
|-----|--------|
|String|'https://github.com/ether/etherpad-lite.git'|

#### database_type

The type of database that etherpad should use. In case of `mysql` or `postgres`,
you'll also have to set the options below.

|Type |Default |
|-----|--------|
|Enum[`dirty`, `mysql`, `sqlite`, `postgres`]|`dirty`|

#### database_host

Host on which the database is running.

|Type |Default |
|-----|--------|
|String|`localhost`|

#### database_user

User (or role) to use, when connecting to the database.

|Type |Default |
|-----|--------|
|String|`etherpad`|

#### database_name

Name of database to connect to.

|Type |Default |
|-----|--------|
|String|`etherpad`|

#### database_password

Password to use when connecting to database.

|Type |Default |
|-----|--------|
|String|`etherpad`|

#### ip

IP on which etherpad will be listening. The default, `undef`, turns into
`null`, and hence NodeJS' default of "all interfaces".

|Type |Default |
|-----|--------|
|String|`undef`|

#### port

Port on which etherpad will be listening.

|Type |Default |
|-----|--------|
|Integer|`9001`|

#### trust_proxy

This value should be set if etherpad is running behind a proxy.

|Type |Default |
|-----|--------|
|Boolean|`false`|

#### max_age

How long clients may use served JavaScript code (in seconds).

|Type |Default |
|-----|--------|
|Integer|21600|

#### minify

Whether to minify the delivered JavaScript and CSS.

|Type |Default |
|-----|--------|
|Boolean|`true`|

#### require_session

Users must have a session to access pads. This effectively allows
only group pads to be accessed.

|Type |Default |
|-----|--------|
|Boolean|`false`|

#### edit_only

Users may edit pads but not create new ones. Pad creation is only
via the API. This applies both to group pads and regular pads.

|Type |Default |
|-----|--------|
|Boolean|`false`|

#### require_authentication

This setting is used if you require authentication of all users.

Note: `/admin` always requires authentication.

|Type |Default |
|-----|--------|
|Boolean|`false`|

#### require_authorization

Require authorization by a module, or a user with is_admin set,
see below.

|Type |Default |
|-----|--------|
|Boolean|`false`|

#### use_default_ldapauth

Merge default ldapauth options to final config of ep_ldapauth plugin. If set to 'false' it can be used to omit default searchDN and searchPWD for anonymous ldap access.

|Type |Default |
|-----|--------|
|Boolean|`true`|

#### plugins_list

Manage etherpad's plugins.

|Type |Default |
|-----|--------|
|Hash[Pattern['ep_*'], Variant[Boolean, Undef]]|{}|

Existing two kinds of plugins:
 * Simple plugins : Supported plugins that does not modify `settings.json`.
 * Advanced plugins : Supported plugins that accept configuration parameters in `settings.json`.

Keys in `plugins_list` must be default plugins name.

Values in `plugins_list` can be:
 * `undef`: Install any simple plugins or advanced plugins with its default configuration.
 * `true` : Install advanced plugins with provided configuration by class attributs. See beelow detailed section about each plugin.
 * `false`: Uninstall any plugins.

List of all plugins is avalable at https://static.etherpad.org/plugins.html

|Plugin name |Supported |
|--------------|----------|
|`ep_button_link`|YES|
|`ep_ldapauth`|YES|
|`ep_mypads`|YES|
|All simple plugins|YES|

If the plugin is not supported, it will be installed but whitout configuration.

Examples :

```puppet
class { 'etherpad':
  ensure            => 'present',
  database_type     => 'mysql',
  database_name     => 'etherpad',
  database_user     => 'etherpad',
  database_password => '37h3rp4d',
  users             => {
    admin => {
      password => 's3cr3t',
      is_admin => true,
    },
    user  => {
      password => 'secret',
      is_admin => false,
    },
  },
  plugins_list => {
    ep_button_link => true,
    ep_align       => undef,
    ep_ldapauth    => false,
  },
}
```

In this case `ep_button_link` will be installed with the configuration in `settings.json`, `ep_align` will be just installed and `ep_ldapauth` will be uninstalled.


```puppet
class { 'etherpad':
  ensure               => 'present',
  database_type        => 'mysql',
  database_name        => 'etherpad',
  database_user        => 'etherpad',
  database_password    => '37h3rp4d',
  plugins_list         => {
    ep_button_link => true,
    ep_align       => undef,
    ep_mypads      => true,
  },
  mypads               => {
    searchBase      =>  'cn=users,cn=accounts,dc=example,dc=com',
    url             =>  'ldaps://ipa.example.com:636',
    bindDN          =>  'uid=binduser,cn=sysaccounts,cn=etc,dc=example,dc=com',
    bindCredentials =>  'bindpassword',
    searchFilter    =>  '(memberOf=cn=etherpad_users,cn=groups,cn=accounts,dc=example,dc=com)'
  },
  ep_local_admin_login => 'my_ep_adminuser',
  ep_local_admin_pwd   => 'my_ep_adminsecret',
}
```

In this case `ep_button_link` and `ep_mypads` will be installed with some configurations in `settings.json`, `ep_align` will be just installed without configuration.

#### button_link

Manage the configuration of `ep_button_link`.

|Type |Default |
|-----|--------|
|Type |'https://www.npmjs.com/package/ep_button_link' |

#### ldapauth

Manage the configuration of `ep_ldapauth`.

|Type |Default |
|-----|--------|
|Type |'https://www.npmjs.com/package/ep_ldapauth' |

#### mypads

Manage the configuration of `ep_mypads`.

|Type |Default |
|-----|--------|
|Type |'https://www.npmjs.com/package/ep_mypads' or 'https://git.framasoft.org/framasoft/Etherpad/ep_mypads/wikis/use-ldap-authentication' |

#### pad_title

Name of your instance

|Type |Default |
|-----|--------|
|Optional[String]|`undef`|

#### default_pad_text

The default text of a pad.

|Type |Default |
|-----|--------|
|String|`Welcome to etherpad!`|

#### logconfig_file

Enable/disable logging to a file.

|Type |Default |
|-----|--------|
|Boolean|`false`|

#### logconfig_file_filename

Specify the file to log to, if logconfig_file is enabled.

|Type |Default |
|-----|--------|
|Optional[String]|`undef`|

#### logconfig_file_max_log_size

The maximum logfile size (megabytes) before rotating the log file.

|Type |Default |
|-----|--------|
|Optional[Integer]|`undef`|

#### logconfig_file_backups

The number of logfiles to keep after rotation.

|Type |Default |
|-----|--------|
|Optional[Integer]|`undef`|

#### logconfig_file_category

Only log a specific category.

|Type |Default |
|-----|--------|
|Optional[String]|`undef`|

#### users

Configure users in settings.json. If both 'users' and 'ldapauth' are set only the latter one will be put into settings.json.

|Type |Default |
|-----|--------|
|Optional[Hash]|`undef`|

#### padoptions

Configure pad options in settings.json.

|Type |Default |
|-----|--------|
|Struct|`noColors => false`, `showControls => true`, `showChat => true`, `showLineNumbers => true`, `useMonospaceFont => false`, `userName => false`, `userColor => false`, `rtl => false`, `alwaysShowChat => false`, `chatAndUsers => false`, `lang => en-gb`|

## Limitations

Currently, only upstart and systemd are supported as Service
providers. More support is highly welcomed.

## Development

Please see [CONTRIBUTING.md](CONTRIBUTING.md) for how to contribute patches!

