# Reads classification rules from Hiera and classifies a node
#
# After classification is done a number of variables are
# considered public and can be used to access the classification
# results.  These are `$classification`, `$classification_classes`,
# `$data` and `$classes`.
class classifier (
  Classifier::Classifications  $rules = {},
  Array[Classifier::Classname] $extra_classes = [],
  Boolean                      $debug = false,
  Boolean                      $validate_enc = true,
  Boolean                      $enc_used = false,
  Optional[String]             $enc_source = undef,
  Optional[String]             $enc_environment = undef
) {

  if $enc_used {
    classifier::debug("The ENC was used and set environment '${enc_environment}' for '${trusted[certname]}' using '${enc_source}'")

    if $validate_enc {
      unless $enc_environment == $::environment {
        fail("Classifier ENC set environment to '${enc_environment}' for '${trusted[certname]}' but the active environment is '${::environment}' refusing to continue")
      }
    }
  } else {
    classifier::debug("The ENC was not used to classify ${trusted[certname]}, environment is ${::environment}")
  }

  class{"classifier::classify":
    rules => $rules,
    debug => $debug
  }

  $classification = $classifier::classify::classification
  $classification_classes = $classifier::classify::classification_classes
  $data = $classifier::classify::data
  $classes = $classification_classes + $extra_classes

  classifier::debug("Extra classes declared for ${trusted[certname]}: ${extra_classes}")
  classifier::debug("Final classes for ${trusted[certname]}: ${classes}")

  class{"classifier::apply":
    classes => $classes,
    debug   => $debug
  }
}
