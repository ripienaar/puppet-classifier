# Performs classification of the node by evaluating its
# Classifier::Classifications as found in hiera
#
# When debug is passed a number of debug notices are
# created that might include sensitive information so
# use with caution
class classifier::classify(
  Classifier::Classifications $rules,
  Boolean $debug
) {
  $classification = classifier::classify($rules)

  if $debug {
    notice("Classification for ${trusted[certname]}: ${classifier::inspect($_result)}")
  }

  # the classes extracted from the classification
  $classification_classes = $classification.map |$c| { $c["classes"] }.flatten

  # data extracted and merged
  $data = $classification.reduce({}) |$r, $c| { $r+ $c["data"] }

  class{"classifier::node_data": data => $data}

  if $debug {
    notice("Classification result for ${trusted[certname]}: ${classifier::inspect($classification)}")
    notice("Properties derived from classification for ${trusted[certname]}: ${classifier::inspect($data)}")
    notice("Classes derived from classification for ${trusted[certname]}: ${classification_classes}")
  }
}
