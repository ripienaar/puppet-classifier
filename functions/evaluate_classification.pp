function classifier::evaluate_classification($classification) {
    $classification["rules"].filter |$rule| {
      classifier::evaluate_rule(
        classifier::fact_fetch($rule["fact"]),
        $rule["operator"],
        $rule["value"],
        !!$rule["invert"]
      )
    }
}
