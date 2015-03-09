class webapp::autorealize(
  $cron   = true,
  $apache = true,
  $drush  = true,
  $mysql  = true,
  $solr   = true,
) {

  validate_bool($cron)
  validate_bool($apache)
  validate_bool($drush)
  validate_bool($mysql)
  validate_bool($solr)

  if $cron {
    Cron           <<| tag == $::fqdn and tag == webapp::instance |>>
  }

  if $apache and defined('::apache') and defined(Class['::apache']) {
    Apache::Vhost  <<| tag == $::fqdn and tag == webapp::instance |>>
    Host           <<| tag == $::fqdn and tag == webapp::instance |>>
    File           <<| tag == $::fqdn and tag == webapp::instance |>>
  }

  if $drush and defined('::drush') and defined(Class['::drush']) {
    Drush::Alias   <<| tag == $::fqdn and tag == webapp::instance |>>
  }

  if $mysql and defined('::mysql::server') and defined(Class['::mysql::server']) {
    Mysql::Db      <<| tag == $::fqdn and tag == webapp::instance |>>
  }

  if $solr and defined('::solr') and defined(Class['::solr']) {
    Solr::Instance <<| tag == $::fqdn and tag == webapp::instance |>>
  }

}

