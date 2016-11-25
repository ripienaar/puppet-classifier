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
  classifier::debug("Classification for ${trusted[certname]}: ${classifier::inspect($rules)}")

  $classification = classifier::classify($rules)

  # the classes extracted from the classification
  $classification_classes = $classification.map |$c| { $c["classes"] }.flatten

  # data extracted and merged
  $data = $classification.reduce({}) |$r, $c| { deep_merge($r, $c["data"]) }

  class{"classifier::node_data": data => $data}

  classifier::debug("Classification result for ${trusted[certname]}: ${classifier::inspect($classification)}")
  classifier::debug("Properties derived from classification for ${trusted[certname]}: ${classifier::inspect($data)}")
  classifier::debug("Classes derived from classification for ${trusted[certname]}: ${classification_classes}")
}
