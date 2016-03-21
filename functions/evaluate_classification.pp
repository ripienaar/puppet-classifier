# Take a single Classifier::Classification and evaluate
# all the rules found in it returning just the rules booleans
#
# @return [Array<Boolean>]
function classifier::evaluate_classification (
  Classifier::Classification $classification
) {
    $classification["rules"].filter |$rule| {
      classifier::evaluate_rule(
        $rule["fact"],
        $rule["operator"],
        $rule["value"],
        !!$rule["invert"])
    }
}
