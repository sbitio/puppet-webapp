# == Class: webapp::autorealize
#
class webapp::autorealize(
  Boolean $cron   = true,
  Boolean $apache = true,
  Boolean $drush  = true,
  Boolean $mysql  = true,
  Boolean $solr   = true,
) {

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
    Mysql_grant    <<| tag == $::fqdn and tag == webapp::instance |>>
  }

  if $solr and defined('::solr') and defined(Class['::solr']) {
    Solr::Instance <<| tag == $::fqdn and tag == webapp::instance |>>
  }

}

