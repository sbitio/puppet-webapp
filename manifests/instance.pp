# webapp::instance
#
# This define is a facility that declares a set of resources related to
# a web application. Resources are declared as exported.
# See init.pp for details on how each node realizes its corresponding
# resources.
#
#
# @param type
#   **Deprecated**. Type of web application. Any value is supported. We only recognize: drupal.
#   In case of drupal, this indicates a drush alias will be declared.
# @param vhost_ensure
#   Indicate if a vhost must be present, absent or undefined.
# @param servername
#   Virtualhost server name. It must be a domain name without www prefix.
#   The prefix is managed by $www_ensure parameter.
# @param serveraliases
#   Virtualhost server aliases. Array of domain names.
# @param ip
#   Virtualhost listen ip.
#   Default: undef (it will use upstream default value)
# @param port
#   Virtualhost listen port.
#   Default: undef (it will use upstream default value)
# @param docroot_folder
#   "App" specific part of the virtualhost document root. The full path of the
#   document root is $docroot_prefix + $docroot_folder + $docroot_suffix.
#   If not specified, the value of $servername will be used.
# @param docroot_prefix
#   Prefix of the virtualhost document root. The full path of the
#   document root is $docroot_prefix + $docroot_folder + $docroot_suffix.
# @param docroot_suffix
#   Suffix of the virtualhost document root. The full path of the
#   document root is $docroot_prefix + $docroot_folder + $docroot_suffix.
# @param docroot_file_params
#   Extra parameters for the docroot ancestor file resource.
#   Yaml example:
#
#     docroot_file_params :
#       owner : deploy
#       group : deploy
#       mode  : 2775
# @param allow_override
#   Array of options for AllowOverride directive.
#   Default: undef (it will use upstream default value)
# @param options
#   Array of options for Options directive.
#   Default: undef (it will use upstream default value)
# @param www_ensure
#   Whether to SEO redirect (permanent). Options:
#    * present: Ensure $servername redirects to www.$servername.
#    * absent : Ensure www.$servername redirects to $servername.
#    * undef  : Don't do any redirection.
# @param www_ensure_proto
#   Protocol to use in SEO redirections. Options:
#    * http
#    * https
# @param aliases
#   Virtualhost Alias directives. It accepts an array of hashes
#   with 'alias' and 'path' keys.
#   Yaml example:
#
#   aliases       :
#     - alias     : /examplecom
#       path      : /var/www/example.com
#     - alias     : /examplenet
#       path      : /var/www/example.net
# @param redirects
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
# @param logs_enable
#   Whether to enable access and error log for the vhosts.
# @param vhost_extra
#   String of directives to append to the VirtualHost.
# @param vhost_extra_params
#   Hash of params to pass directly to the main ::apache::vhost instance.
#   Note: Params defined here take precedence over the ones computed by webapp.
# @param hosts_ensure
#   Whether to create an entry in the hosts file for each domain.
# @param cron
#  Hash with cron definitions. It directly creates 'cron' resource types.
#  If 'tag' key is specified, it won't be assigned the general tags.
# @param db_ensure
#   Whether this webapp has a database.
# @param db_name
#   Name of the database.
#   If not specified, the first 64 chars of the sanitized value of $name will be used.
# @param db_user
#   User to access grants to the database.
#   If not specified, the first 16 chars of $db_name will be used.
# @param db_pass
#   User password.
#   If not specified, the value of $db_user will be used.
# @param db_grants
#  Hash of grant definitions. See https://github.com/puppetlabs/puppetlabs-mysql#mysql_grant
#  for details.
# @param solr_ensure
#   **Deprecated**. Whether this webapp has a solr instance.
# @param solr_name
#   **Deprecated**. Name of the solr instance folder. Defaults to $name.
# @param solr_folder
#   **Deprecated**. Equivalent to $docroot_folder.
# @param solr_prefix
#   **Deprecated**. Equivalent to $docroot_prefix.
# @param solr_suffix
#   **Deprecated**. Equivalent to $docroot_suffix.
# @param solr_version
#   **Deprecated**. Solr version. This is one of the "available version".
#   See sbitio/puppet-solr for detals.
# @param solr_initialize
#   **Deprecated**. Boolean indicating whether to initialize the solr instance with the example config.
# @param tags
#   Array of tags to tag the exported resources it will create.
#   This tags are used to realize the resources on each node.
#   See init.pp for details.
#
define webapp::instance(
  Optional[String] $type           = undef,
# Apache
  Optional[Enum['present', 'absent']] $vhost_ensure     = undef,
  String $servername                                    = $name,
  Array[String] $serveraliases                          = [],
  Optional[Stdlib::Host] $ip                            = undef,
  Optional[Stdlib::Port] $port                          = undef,
  Optional[String] $docroot_folder                      = undef,
  Stdlib::Absolutepath $docroot_prefix                  = '/var/www',
  String $docroot_suffix                                = 'current/docroot',
  Hash[String, Any] $docroot_file_params                = {},
  Optional[Array[String]] $allow_override               = undef,
  Optional[Array[String]] $options                      = undef,
  Optional[Enum['present', 'absent']] $www_ensure       = undef,
  Enum['http', 'https'] $www_ensure_proto               = 'http',
  Optional[Array[Hash[String, String]]] $aliases        = undef,
  Hash[Integer, Array[Hash[String, String]]] $redirects = {},
  Boolean $logs_enable                                  = true,
  Variant[Array[String], String] $vhost_extra           = '',
  Hash[String, Any] $vhost_extra_params                 = {},

# Hosts
  Optional[Enum['present', 'absent']] $hosts_ensure     = undef,

# Cron
  Hash[String, Hash[String, String]] $cron              = {},

# Mysql
  Optional[Enum['present', 'absent']] $db_ensure        = undef,
  String $db_name                                       = $name,
  Optional[String] $db_user                             = undef,
  Optional[String] $db_pass                             = undef,
  Optional[Hash[String, Hash]] $db_grants               = undef,

# Solr
  Optional[Enum['present', 'absent']] $solr_ensure      = undef,
  String $solr_name                                     = $name,
  Optional[String] $solr_folder                         = undef,
  Optional[String] $solr_prefix                         = undef,
  String $solr_suffix                                   = 'current/solr',
  Optional[String] $solr_version                        = undef,
  Boolean $solr_initialize                              = false,

  Array[String] $tags                                   = [$::fqdn],
) {

################################################################[ Web Head ]###
  if $vhost_ensure {
    validate_re($servername, '^(?!www\.)', "The webapp::instance servername ${servername} must not start with www.")
    if is_array($vhost_extra) {
      $_vhost_extra = join(flatten($vhost_extra), "\n")
    }
    elsif is_string($vhost_extra) {
      $_vhost_extra = $vhost_extra
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
    $file_docroot_name = "${docroot_prefix}/${real_docroot_folder}"
    if !defined(File[$file_docroot_name]) {
      $docroot_file_defaults = {
        ensure => $ensure_docroot_parent,
        tag    => $tags,
      }
      $file_params = merge($docroot_file_defaults, $docroot_file_params)
      @@file { $file_docroot_name :
        * => $file_params,
      }
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
      undef, default: {
        $servername_real = $servername
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
        redirect_dest   => "${www_ensure_proto}://${servername_real}/",
        redirect_status => 'permanent',
        access_log      => $logs_enable,
        error_log       => $logs_enable,
        tag             => $tags,
      }
    }

    $redirects_fragment = template('webapp/apache/redirects.erb')
    $custom_fragment    = "${redirects_fragment}\n${_vhost_extra}"
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

    if $type != undef {
      warning('\$type support is deprecated and will be removed in future versions!')
    }
    if ($type == 'drupal') {
      @@drush::alias { $name:
        ensure => $vhost_ensure,
        uri    => $servername_real,
        root   => $docroot,
        tag    => $tags,
      }
    }

    if $hosts_ensure {
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
      *   => $params,
    }
  }

################################################################[ Database ]###
  if $db_ensure {
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
    warning('Solr support is deprecated and will be removed in future versions!')

    $real_solr_prefix = pick($solr_prefix, $docroot_prefix)
    $real_solr_folder = pick($solr_folder, $real_docroot_folder)
    $solr_directory   = "${real_solr_prefix}/${real_solr_folder}/${solr_suffix}"

    @@solr::instance { $solr_name:
      ensure     => $solr_ensure,
      directory  => $solr_directory,
      version    => $solr_version,
      initialize => $solr_initialize,
      tag        => $tags,
    }
  }
}

