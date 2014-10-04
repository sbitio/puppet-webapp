class webapp(
  $autorealize       = true,
  $instance_defaults = {},
  $instances         = {},
) {

  create_resources('::webapp::instance', $instances, $instance_defaults)

  if $autorealize {
    if defined('::apache') and defined(Class['::apache']) {
      Apache::Vhost  <<| tag == $::fqdn and tag == webapp::instance |>>
      Host           <<| tag == $::fqdn and tag == webapp::instance |>>
      File           <<| tag == $::fqdn and tag == webapp::instance |>>
    }

    if defined('::drush') and defined(Class['::drush']) {
      Drush::Alias   <<| tag == $::fqdn and tag == webapp::instance |>>
    }

    if defined('::mysql::server') and defined(Class['::mysql::server']) {
      Mysql::Db      <<| tag == $::fqdn and tag == webapp::instance |>>
    }

    if defined('::solr') and defined(Class['::solr']) {
      Solr::Instance <<| tag == $::fqdn and tag == webapp::instance |>>
    }
  }
}

