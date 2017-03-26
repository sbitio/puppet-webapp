# == Class: webapp
#
class webapp(
  $instance_defaults = {},
) {

  $instances = hiera_hash('webapp::instances', {})

  create_resources('::webapp::instance', $instances, $instance_defaults)

  require webapp::autorealize

}

