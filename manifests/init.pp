class webapp(
  $autorealize       = true,
  $instance_defaults = {},
  $instances         = {},
) {

  create_resources('::webapp::instance', $instances, $instance_defaults)

  if $autorealize {
    if defined('::apache') and defined(Class['::apache']) {
      Apache::Vhost  <<| tag == $::fqdn |>>
      Host           <<| tag == $::fqdn |>>
    }

    if defined('::drush') and defined(Class['::drush']) {
      Drush::Alias   <<| tag == $::fqdn |>>
    }

    if defined('::mysql::server') and defined(Class['::mysql::server']) {
      Mysql::Db      <<| tag == $::fqdn |>>
    }

    if defined('::solr') and defined(Class['::solr']) {
      Solr::Instance <<| tag == $::fqdn |>>
    }
  }
}

