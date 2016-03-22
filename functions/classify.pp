# Given a set of classification rules this will itterate them
# and create a classification for the current node
#
# @return [Classifier::Node] of classification data
function classifier::classify (
  Classifier::Classifications $rules,
  Hash $empty = {}
) {
  $classes = $rules.map |$c_name, $c_body| {
    $matching = classifier::evaluate_classification($c_body)

    $classification = {
      "name"    => $c_name,
      "classes" => $c_body["classes"] ? { Undef => [], default => $c_body["classes"] },
      "data"    => $c_body["data"] ? { Undef => {}, default => $c_body["data"]}
    }

    # defaults to 'all' matching
    if $c_body["match"] == "any" {
      if $matching.size > 0 {
        $classification
      } else {
        $empty
      }
    } else {
      if $c_body["rules"].size == $matching.size {
        $classification
      } else {
        $empty
      }
    }
  }

  $classes.filter |$c| { !$c.empty }
}
