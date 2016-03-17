class classifier::apply(
  Array[Classifier::Classname] $classes,
  Boolean $debug
) {
  $classes.each |$class| {
    include($class)
  }
}
