class classifier::classify(
  Classifier::Classifications $rules,
  Boolean $debug
) {
  $_result = classifier::classify($rules)

  if $debug {
    notice("Classification for ${trusted[certname]}: ${classifier::inspect($_result)}")
  }

  $classification = $_result.filter |$c| { !$c.empty }

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
