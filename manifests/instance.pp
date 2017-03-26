# == Defined type: webapp::instance
#
# This define is a facility that declares a set of resources related to
# a web application. Resources are declared as exported.
# See init.pp for details on how each node realizes its corresponding
# resources.
#
# === Parameters
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
# [*ip*]
#   Virtualhost listen ip.
#
# [*port*]
#   Virtualhost listen port. Defaults to 80.
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
#   Default: "current/htdocs".
#
# [*allow_override*]
#   Array of options for AllowOverride directive.
#   Default: undef (it will use upstream default value)
#
# [*options*]
#   Array of options for Options directive.
#   Default: undef (it will use upstream default value)
#
# [*www_ensure*]
#   Whether to SEO redirect (permanent). Options:
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
# [*vhost_extra_params*]
#   Hash of params to pass directly to the main ::apache::vhost instance.
#   Note: Params defined here take precedence over the ones computed by webapp.
#
# [*hosts_ensure*]
#   Whether to create an entry in the hosts file for each domain.
#   Valid values: present, absent, undef.
#   Default: present.
#
# [*cron*]
#  Hash with cron definitions. It directly creates 'cron' resource types.
#  If 'tag' key is specified, it won't be assigned the general tags.
#
# [*db_ensure*]
#   Whether this webapp has a database.
#   Valid values: present, absent, undef.
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
# [*db_grants*]
#  Hash of grant definitions. See https://github.com/puppetlabs/puppetlabs-mysql#mysql_grant
#  for details.
#
# [*solr_ensure*]
#   Whether this webapp has a solr instance.
#   Valid values: present, absent, undef.
#   Default: undef.
#
# [*solr_name*]
#   Name of the solr instance folder. Defaults to $name.
#
# [*solr_folder*]
#   Equivalent to $docroot_folder.
#
# [*solr_prefix*]
#   Equivalent to $docroot_prefix.
#
# [*solr_suffix*]
#   Equivalent to $docroot_suffix.
#
# [*solr_version*]
#   Solr version. This is one of the "available version".
#   See sbitio/puppet-solr for detals.
#
# [*solr_initialize*]
#   Boolean indicating whether to initialize the solr instance with the example config.
#   Default: false.
#
# [*tags*]
# Array of tags to tag the exported resources it will create.
# This tags are used to realize the resources on each node.
# See init.pp for details.
#
define webapp::instance(
  $type            = undef,
# Apache
  $vhost_ensure        = present,
  $servername          = $name,
  $serveraliases       = [],
  $ip                  = undef,
  $port                = undef,
  $docroot_folder      = undef,
  $docroot_prefix      = '/var/www',
  $docroot_suffix      = 'current/htdocs',
  $allow_override      = undef,
  $options             = undef,
  $www_ensure          = undef,
  $aliases             = undef,
  $redirects           = {},
  $logs_enable         = true,
  $vhost_extra         = '',
  $vhost_extra_params  = {},

# Hosts
  $hosts_ensure    = present,

# Cron
  $cron            = {},

# Mysql
  $db_ensure       = present,
  $db_name         = $name,
  $db_user         = undef,
  $db_pass         = undef,
  $db_grants       = undef,

# Solr
  $solr_ensure     = undef,
  $solr_name       = $name,
  $solr_folder     = undef,
  $solr_prefix     = undef,
  $solr_suffix     = 'current/solr',
  $solr_version    = undef,
  $solr_initialize = false,

  $tags            = [$::fqdn],
) {

  $ensure_options = [ present, absent ]

################################################################[ Web Head ]###
  if !($vhost_ensure in [undef, '']) {
    if ! ($vhost_ensure in $ensure_options) {
      fail("'${vhost_ensure}' is not a valid value for vhost_ensure. Valid values: ${ensure_options}.")
    }

    validate_re($servername, '^(?!www\.)', "The webapp::instance servername ${servername} must not start with www.")
    validate_hash($redirects)
    validate_string($vhost_extra)
    validate_bool($logs_enable)
    if $ip != undef {
      if ! is_ip_address($ip) {
        fail("'${ip}' is not a valid IP address.")
      }
    }

    # Upon the deployment strategy the docroot may be a directory or a symlink.
    # We won't ensure anything for the docroot. It is up to the deployment tool.
    # We just ensure the parent directory.
    $real_docroot_folder = pick($docroot_folder, $servername)
    $docroot = "${docroot_prefix}/${real_docroot_folder}/${docroot_suffix}"
    $ensure_docroot_parent = $vhost_ensure ? {
      absent  => absent,
      present => directory,
    }
    @@file { "${docroot_prefix}/${real_docroot_folder}":
      ensure => $ensure_docroot_parent,
      tag    => $tags,
    }

    # Redirect example.com to www.example.com or the inverse, or nothing at all.
    case $www_ensure {
      present: {
        $servername_source = $servername
        $servername_real   = "www.${servername}"
      }
      absent: {
        $servername_source = "www.${servername}"
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
      @@apache::vhost { $servername_source:
        ensure          => $vhost_ensure,
        servername      => $servername_source,
        ip              => $ip,
        port            => $port,
        docroot         => $docroot,
        options         => $options,
        manage_docroot  => false,
        redirect_source => '/',
        redirect_dest   => "http://${servername_real}/",
        redirect_status => 'permanent',
        access_log      => $logs_enable,
        error_log       => $logs_enable,
        tag             => $tags,
      }
    }

    $redirects_fragment = template('webapp/apache/redirects.erb')
    $custom_fragment    = "${redirects_fragment}\n${vhost_extra}"
    @@apache::vhost { $servername_real:
      ensure          => $vhost_ensure,
      servername      => $servername_real,
      serveraliases   => $serveraliases,
      ip              => $ip,
      port            => $port,
      docroot         => $docroot,
      options         => $options,
      override        => $allow_override,
      manage_docroot  => false,
      aliases         => $aliases,
      custom_fragment => $custom_fragment,
      access_log      => $logs_enable,
      error_log       => $logs_enable,
      tag             => $tags,
      *               => $vhost_extra_params,
    }

    if ($type == 'drupal') {
      @@drush::alias { $name:
        ensure => $vhost_ensure,
        uri    => $servername_real,
        root   => $docroot,
        tag    => $tags,
      }
    }

    if !($hosts_ensure in [undef, '']) {
      # Merge hosts and filter those with an *.
      $hosts = flatten([$servername, $serveraliases])
      $real_hosts = difference($hosts, grep($hosts, '\*'))
      @@host { $real_hosts:
        ensure => $hosts_ensure,
        ip     => '127.0.0.1',
        tag    => $tags,
      }
    }
  }

####################################################################[ Cron ]###
  $cron.each | String $name, Hash $params| {
    @@cron { $name:
      tag => $tags,
      * => $params,
    }
  }

################################################################[ Database ]###
  if !($db_ensure in [undef, '']) {
    if ! ($db_ensure in $ensure_options) {
      fail("'${db_ensure}' is not a valid value for db_ensure. Valid values: ${ensure_options} and undef.")
    }

    # Use defaults if no $db_user or $db_pass is given.
    $real_db_name = regsubst($db_name, '[^0-9a-z_]', '_', 'IG')
    $real_db_user = pick($db_user, $real_db_name)
    $real_db_pass = pick($db_pass, $real_db_user)

    validate_slength($real_db_name, 64)
    validate_slength($real_db_user, 16)

    @@mysql::db { $real_db_name:
      ensure   => $db_ensure,
      user     => $real_db_user,
      password => $real_db_pass,
      host     => '%',
      tag      => $tags,
    }

    if !empty($db_grants) {
      validate_hash($db_grants)
      $db_grants.each | String $name, Hash $params| {
        @@mysql_grant { $name:
          tag => $tags,
          *   => $params,
        }
      }
    }

  }

#####################################################################[ Solr ]###
  if $solr_ensure != undef {
    if ! ($solr_ensure in $ensure_options) {
      fail("'${solr_ensure}' is not a valid value for solr_ensure. Valid values: ${ensure_options} and undef.")
    }

    $real_solr_prefix = pick($solr_prefix, $docroot_prefix)
    $real_solr_folder = pick($solr_folder, $real_docroot_folder)
    $solr_directory   = "${real_solr_prefix}/${real_solr_folder}/${solr_suffix}"

    @@solr::instance { $solr_name:
      ensure      => $solr_ensure,
      directory   => $solr_directory,
      version     => $solr_version,
      initialize  => $solr_initialize,
      tag         => $tags,
    }
  }
}

