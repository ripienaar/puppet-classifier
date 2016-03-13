function classifier::classify ($rules) {
  $classes = $rules.map |$rule_name, $rule_body| {
    $matching = $rule_body["rules"].filter |$rule| {
      classifier::evaluate_rule(
        classifier::fact_fetch($rule["fact"]),
        $rule["operator"],
        $rule["value"],
        !!$rule["invert"]
      )
    }

    if $rule_body["match"] == "all" {
      if $rule_body["rules"].size == $matching.size {
        classifier::debug("Including classes from rule '${rule_name}': ${rule_body["classes"]}")
        $rule_body["classes"]
      } else {
        []
      }
    } else {
      if $matching.size > 0 {
        classifier::debug("Including classes from rule '${rule_name}': ${rule_body["classes"]}")
        $rule_body["classes"]
      } else {
        []
      }
    }
  }

  $classes.flatten
}
