# webapp
#
# This class is the entry point to declare webapp resources and realize them on nodes.
#
#
# @param instance_defaults
#   Default values for instances declarations. See `webapp::instance` for details.
#
class webapp(
  Optional[Hash[String, Hash]] $instance_defaults = {},
) {

  $instances = hiera_hash('webapp::instances', {})

  create_resources('::webapp::instance', $instances, $instance_defaults)

  require webapp::autorealize

}
