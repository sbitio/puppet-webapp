# webapp
#
# This class is the entry point to declare webapp resources and realize them on nodes.
#
#
# @param instance_defaults
#   Default values for instances declarations. See `webapp::instance` for details.
# @param instances
#   Instances to declare.
#
class webapp(
  Optional[Hash[String, Hash]] $instance_defaults = {},
  Optional[Hash[String, Hash]] $instances = {},
) {

  create_resources('::webapp::instance', $instances, $instance_defaults)
  require webapp::autorealize

}
