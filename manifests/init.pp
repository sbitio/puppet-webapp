# == Class: webapp
#
class webapp(
  Hash $instances,
  Hash $instance_defaults,
) {

  $instances.each |String $name, Hash $params| {
    webapp::instance {$name:
      * => deep_merge($instance_defaults, $params),
    }
  }

  require webapp::autorealize
}
