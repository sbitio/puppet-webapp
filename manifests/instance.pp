# == Defined type: webapp::instance
#
# This define is a facility that declares a set of resources related to
# a web application. Resources are declared as exported.
# See init.pp for details on how each node realizes its corresponding
# resources.
#
# === Parameters
#
# [*creation_mode*]
#   Resources creation mode. Specify whether the resources will be created
#   locally for this node or instead they're created as exported resources.
#   Valid values: local, exported.
#   Default: local.
#
# [*type*]
#   Type of web application. Any value is supported. We only recognize: drupal.
#   In case of drupal, this indicates a drush alias will be declared.
#
# [*vhost_ensure*]
#   Indicate if a vhost must be present, absent or undefined.
#   Valid values: present, absent, undef.
#   Default: present.
#
# [*servername*]
#   Virtualhost server name. It must be a domain name without www prefix.
#   The prefix is managed by $www_ensure parameter.
#
# [*serveraliases*]
#   Virtualhost server aliases. Array of domain names.
#
# [*port*]
#   Virtualhost listen port.
#
# [*docroot_folder*]
#   "App" specific part of the virtualhost document root. The full path of the
#   document root is $docroot_prefix + $docroot_folder + $docroot_suffix.
#   Default: $servername.
#
# [*docroot_prefix*]
#   Prefix of the virtualhost document root. The full path of the
#   document root is $docroot_prefix + $docroot_folder + $docroot_suffix.
#   Default: "/var/www".
#
# [*docroot_suffix*]
#   Suffix of the virtualhost document root. The full path of the
#   document root is $docroot_prefix + $docroot_folder + $docroot_suffix.
#   Default: "current".
#
# [*allow_override*]
#   Array of options for AllowOverride directive.
#   Default: ['None']
#
# [*www_ensure*]
#   Wether to SEO redirect (permanent). Options:
#    * present: Ensure $servername redirects to www.$servername.
#    * absent : Ensure www.$servername redirects to $servername.
#    * undef  : Don't do any redirection.
#
# [*aliases*]
#   Virtualhost Alias directives. It accepts an array of hashes
#   with 'alias' and 'path' keys.
#   Yaml example:
#
#   aliases       :
#     - alias     : /examplecom
#       path      : /var/www/example.com
#     - alias     : /examplenet
#       path      : /var/www/example.net
#
# [*redirects*]
#   Virtualhost Redirect directives. It accepts a hash of arrays
#   of hashes where the keys of the outer hash are redirect codes
#   and the keys of the inner hash are 'source' and 'dest'.
#   Yaml example:
#
#   redirects     :
#     301         :
#       - source  : /rp1
#         dest    : "http://example.com/rp1"
#       - source  : /rp2
#         dest    : "http://example.com/rp2"
#     302         :
#       - source  : /rt
#         dest    : "http://example.com/rt"
#
# [*logs_enable*]
#   Boolean indicating whether to enable access and error log for the vhosts.
#   Default: true.
#
# [*vhost_extra*]
#   String of directives to append to the VirtualHost.
#
# [*db_ensure*]
#   Whether this webapp has a database.
#   Valid values: present, absent.
#   Default: present.
#
# [*db_name*]
#   Name of the database. Defaults to $name.
#
# [*db_user*]
#   User to access grants to the database. Defaults to $db_name.
#
# [*db_pass*]
#   User password. Defaults to $db_user.
#
# [*solr_ensure*]
#   .
#
# [*solr_name*]
#   .
#
# [*solr_version*]
#   .
#
# [*solr_skel*]
#   .
#
# [*solr_schema*]
#   .
#
# [*solr_config*]
#   .
#
# [*solr_protwords*]
#   .
#
# [*solr_war*]
#   .
#
# [*tags*]
# Array of tags to tag the exported resources it will create.
# This tags are used to realize the resources on each node.
# See init.pp for details.
#
define webapp::instance(
  $creation_mode   = $webapp::creation_mode,
  $type            = undef,
# Apache
  $vhost_ensure    = present,
  $servername      = $name,
  $serveraliases   = [],
  $port            = '80',
  $docroot_folder  = undef,
  $docroot_prefix  = '/var/www',
  $docroot_suffix  = 'current/htdocs',
  $allow_override  = ['None'],
  $www_ensure      = undef,
  $aliases         = undef,
  $redirects       = {},
  $logs_enable     = true,
  $vhost_extra     = '',

# Mysql
  $db_ensure       = present,
  $db_name         = $name,
  $db_user         = undef,
  $db_pass         = undef,

# Solr
  $solr_ensure     = undef,
  $solr_name       = $name,
  $solr_folder     = undef,
  $solr_prefix     = undef,
  $solr_suffix     = 'current/solr',
  $solr_version    = undef,
  $solr_initialize = false,

  $tags            = [],
) {

  case $creation_mode {
    'local': {
      $prefix = ''
    }
    'exported': {
      $prefix = '@@'
    }
    default: {
      fail("'${creation_mode}' is not a valid value for creation_mode. Valid values: local, exported.")
    }
  }

  $ensure_options = [ present, absent ]

################################################################[ Web Head ]###
  if $vhost_ensure != undef {
    if ! ($vhost_ensure in $ensure_options) {
      fail("'${vhost_ensure}' is not a valid value for vhost_ensure. Valid values: ${ensure_options}.")
    }

    validate_re($servername, '^(?!www\.)', "The webapp::instance servername $servername must not start with www.")
    validate_array($allow_override)
    validate_hash($redirects)
    validate_string($vhost_extra)
    validate_bool($logs_enable)

    # Upon the deployment strategy the docroot may be a directory or a symlink.
    # We won't ensure anything for the docroot. It is up to the deployment tool.
    # We just ensure the parent directory.
    $real_docroot_folder = pick($docroot_folder, $servername)
    $docroot = "${docroot_prefix}/${real_docroot_folder}/${docroot_suffix}"
    $ensure_docroot_parent = $vhost_ensure ? {
      absent  => absent,
      present => directory,
    }
    $file_docroot_name = "${docroot_prefix}/${real_docroot_folder}"
    $file_docroot_params = {
      ensure => $ensure_docroot_parent,
      tag    => $tags,
    }
    if !defined(File[$file_docroot_name]) {
      create_resources("${prefix}file", { "${file_docroot_name}" => $file_docroot_params } )
    }

    # Redirect example.com to www.example.com or the inverse, or nothing at all.
    case $www_ensure {
      present: {
        $servername_source = $servername
        $servername_real   = "www.$servername"
      }
      absent: {
        $servername_source = "www.$servername"
        $servername_real   = $servername
      }
      undef: {
        $servername_real = $servername
      }
      default: {
        fail("'${www_ensure}' is not a valid value for www_ensure. Valid values: ${ensure_options} and undef.")
      }
    }
    if $www_ensure != undef {
      $apache_vhost_redirector_params = {
        ensure          => $vhost_ensure,
        port            => $port,
        docroot         => $docroot,
        manage_docroot  => false,
        redirect_source => '/',
        redirect_dest   => "http://${servername_real}",
        redirect_status => 'permanent',
        access_log      => $logs_enable,
        error_log       => $logs_enable,
        tag             => $tags,
      }
      if !defined(Apache::Vhost[$servername_source]) {
        create_resources("${prefix}apache::vhost", { "${servername_source}" => $apache_vhost_redirector_params } )
      }
    }

    $redirects_fragment = template('webapp/apache/redirects.erb')
    $custom_fragment    = "${redirects_fragment}\n${vhost_extra}"
    $apache_vhost_params = {
      ensure          => $vhost_ensure,
      serveraliases   => $serveraliases,
      port            => $port,
      docroot         => $docroot,
      override        => $allow_override,
      manage_docroot  => false,
      aliases         => $aliases,
      custom_fragment => $custom_fragment,
      access_log      => $logs_enable,
      error_log       => $logs_enable,
      tag             => $tags,
    }
    if !defined(Apache::Vhost[$servername_real]) {
      create_resources("${prefix}apache::vhost", { "${servername_real}" => $apache_vhost_params } )
    }

    if ($type == 'drupal') {
      $drush_alias = {
        ensure => $vhost_ensure,
        uri    => $servername_real,
        root   => $docroot,
        tag    => $tags,
      }
      if !defined(Drush::Alias[$name]) {
        create_resources("${prefix}drush::alias", { "${name}" => $drush_alias } )
      }
    }

    # Merge hosts and filter those with an *.
    $hosts = flatten([$servername, $serveraliases])
    $real_hosts = difference($hosts, grep($hosts, '\*'))
    $real_hosts_params = {
      ensure => $vhost_ensure,
      ip     => '127.0.0.1',
      tag    => $tags,
    }
    webapp::instance::create_host { $real_hosts :
      prefix => $prefix,
      params => $real_hosts_params,
    }
  }

###########################################################[ Load Balancer ]###

################################################################[ Database ]###
  if $db_ensure != undef {
    if ! ($db_ensure in $ensure_options) {
      fail("'${db_ensure}' is not a valid value for db_ensure. Valid values: ${ensure_options} and undef.")
    }

    # Use defaults if no $db_user or $db_pass is given.
    $real_db_user = pick($db_user, $db_name)
    $real_db_pass = pick($db_pass, $real_db_user)

    validate_slength($db_name, 64)
    validate_slength($real_db_user, 16)

    $mysql_db_params = {
      ensure   => $db_ensure,
      user     => $real_db_user,
      password => $real_db_pass,
      host     => '%',
      tag      => $tags,
    }
    if !defined(Mysql::Db[$db_name]) {
      create_resources("${prefix}mysql::db", { "${db_name}" => $mysql_db_params } )
    }
  }

#####################################################################[ Solr ]###
  if $solr_ensure != undef {
    if ! ($solr_ensure in $ensure_options) {
      fail("'${solr_ensure}' is not a valid value for solr_ensure. Valid values: ${ensure_options} and undef.")
    }

    $real_solr_prefix = pick($solr_prefix,$docroot_prefix)
    $real_solr_folder = pick($solr_folder, $servername)
    $solr_directory   = "${real_solr_prefix}/${real_solr_folder}/${solr_suffix}"

    $solr_instance_params = {
      ensure      => $solr_ensure,
      directory   => $solr_directory,
      version     => $solr_version,
      initialize  => $solr_initialize,
      tag         => $tags,
    }

    if !defined(Solr::Instance[$solr_name]) {
      create_resources("${prefix}solr::instance", { "${solr_name}" => $solr_instance_params } )
    }
  }
}
define webapp::instance::create_host($prefix, $params) {
  if !defined(Host[$name]) {
    create_resources("${prefix}host", { "${name}" => $params } )
  }
}

