function classifier::evaluate_classification(
  Classifier::Classification $classification
) {
    $classification["rules"].filter |$rule| {
      classifier::evaluate_rule(
        $rule["fact"],
        $rule["operator"],
        $rule["value"],
        !!$rule["invert"]
      )
    }
}
