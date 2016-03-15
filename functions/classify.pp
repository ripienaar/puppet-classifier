function classifier::classify ($rules, $empty = {}) {
  $classes = $rules.map |$c_name, $c_body| {
    $matching = classifier::evaluate_classification($c_body)

    $classification = {
      "name"    => $c_name,
      "classes" => $c_body["classes"],
      "data"    => $c_body["data"] ? { Undef => {}, default => $c_body["data"]}
    }

    # defaults to 'all' matching
    if $c_body["match"] == "any" {
      if $matching.size > 0 { $classification } else { $empty }
    } else {
      if $c_body["rules"].size == $matching.size { $classification } else { $empty }
    }
  }

  $classes.flatten
}
