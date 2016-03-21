# Reads classification rules from Hiera and classifies a node
#
# After classification is done a number of variables are
# considered public and can be used to access the classification
# results.  These are `$classification`, `$classification_classes`,
# `$data` and `$classes`.
class classifier (
  Classifier::Classifications  $rules = {},
  Array[Classifier::Classname] $extra_classes = [],
  Boolean                      $debug = false
) {
  class{"classifier::classify":
    rules => $rules,
    debug => $debug
  }

  $classification = $classifier::classify::classification
  $classification_classes = $classifier::classify::classification_classes
  $data = $classifier::classify::data
  $classes = $classification_classes + $extra_classes

  if $debug {
    notice("Extra classes declared for ${trusted[certname]}: ${extra_classes}")
    notice("Final classes for ${trusted[certname]}: ${classes}")
  }

  class{"classifier::apply":
    classes => $classes,
    debug   => $debug
  }
}
