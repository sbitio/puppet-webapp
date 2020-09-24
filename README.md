# Puppet Webapp

[![puppet forge version](https://img.shields.io/puppetforge/v/sbitio/webapp.svg)](http://forge.puppetlabs.com/sbitio/webapp) [![last tag](https://img.shields.io/github/tag/sbitio/puppet-webapp.svg)](https://github.com/sbitio/puppet-webapp/tags)

Wrapper to create resources that compound webapps.

Resources are declared exported, and realized on the same node by default.

Exported resources are tagged with node's FQDN and realized in
those nodes upon the presence of the classes that implements
the resources.


## Dependencies

This module does not have any hard dependency (but stdlib) so
it can work infrastructure-wide.

These are the modules Webapp works with:

 * [puppetlabs/apache](https://forge.puppetlabs.com/puppetlabs/apache)
 * [puppetlabs/mysql](https://forge.puppetlabs.com/puppetlabs/mysql)
 * [sbitio/solr](https://github.com/sbitio/puppet-solr)
 * [jonhattan/drush](https://forge.puppetlabs.com/jonhattan/drush)


## How it works

First, include webapp class in each node of your infrastructure
that may realize a part of the webapp (apache, mysql, solr).

Second, create webapp instances tagged with the fqdn of each
node involved.

Webapp instances must be created only on one node. It doesn't need to
be one of the tag nodes. For example, use the one you consider
the master.


## Example of use

Class `webapp` accepts `$instances` and `$instance_defaults` parameters.
So you can define webapps in hiera as follows:

```yaml
---
webapp::instance_defaults :
  port         : 80
  db_ensure    : present
  hosts_ensure : present
  vhost_ensure : present
  tags         :
    - dbserver
    - webhead1
    - webhead2

webapp::instances :

# Create a webapp called `foobar.com`.
#  - Servername is by default the resource name: foobar.com
#  - Database name is derived from the resource name: foobar_com
#  - Database username and password are the database name.
  foobar.com      : {}

# Create webapp `barbaz.com` without database.
# Providing ~ or null as the value for db_ensure means undef.
  barbaz.com      :
    db_ensure     : ~

# Create webapp with name `ex`. This is the database name and user. Password
# is provided explicitly. Servername is provided explicitly, along with
# redirects and custom configuration for the virtual host.
# `vhost_ensure : present` will enforce a redirect 301 from example.com
# to www.example.com.
# This webapp is declared of type `drupal`, so a drush alias (name `ex`) will
# also be declared.
  ex              :
    type          : drupal
    servername    : example.com
    www_ensure    : present
    serveraliases :
      - example.net
      - www.example.net
    redirects     :
      '302'       :
        - source  : /under-construction
          dest    : http://www.example.info/landing
    vhost_extra   : |
      ExpiresActive  On
      ExpiresDefault "access plus 10 minutes"
    db_pass       : s3cr3t
    db_grants     :
      'root@localhost/*.*':
        options    : ['GRANT']
        privileges : ['ALL']
        table      : '*.*'
        user       : 'root@localhost'
      'reader@localhost/ex.*'
        options    : ['GRANT']
        privileges : ['SELECT']
        table      : 'ex.*'
        user       : 'reader@localhost'
    cron           :
      cron1 :
        command : '/usr/local/bin/cronjob.sh'
        hour    : 23
        minute  : 12
```

As shown webapp instances allows to define the virtualhost, database or
solr instance behaviour to some extent. See [webapp/instance.pp](https://github.com/sbitio/puppet-webapp/blob/master/manifests/instance.pp)
for detailed documentation on accepted parameters.

## License

MIT License, see LICENSE file

## Contact

Use contact form on http://sbit.io

## Support

Please log tickets and issues on [GitHub](https://github.com/sbitio/puppet-webapp)

