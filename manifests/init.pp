# == Class: webapp
#
class webapp(
  $creation_mode     = 'local',
  $instance_defaults = {},
) {

  $instances = hiera_hash('webapp::instances', {})

  $creation_modes = [ 'local', 'exported' ]
  if ! ($creation_mode in $creation_modes) {
    fail("'${creation_mode}' is not a valid value for creation_mode. Valid values: ${creation_modes}.")
  }

  create_resources('::webapp::instance', $instances, $instance_defaults)

  require webapp::autorealize

}

