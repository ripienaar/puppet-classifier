# Includes a list of classes on this node
class classifier::apply(
  Array[Classifier::Classname] $classes,
  Boolean $debug
) {
  $classes.each |$class| {
    include($class)
  }
}
