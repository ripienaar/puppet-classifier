class classifier::apply($classes, $debug) {
  $classes.each |$class| {
    include($class)
  }
}
