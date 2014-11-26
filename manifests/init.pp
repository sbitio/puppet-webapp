class webapp(
  $creation_mode     = 'local',
  $autorealize       = false,
  $instance_defaults = {},
  $instances         = hiera_hash('webapp::instances', {}),
) {

  $creation_modes = [ 'local', 'exported' ]
  if ! ($creation_mode in $creation_modes) {
    fail("'${creation_mode}' is not a valid value for creation_mode. Valid values: ${creation_modes}.")
  }

  create_resources('::webapp::instance', $instances, $instance_defaults)

  if ($creation_mode == 'exported' and $autorealize) {
    require autorealize
  }
}

