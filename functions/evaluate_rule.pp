# Evaluate a single expression made up of a left, right and operator
#
# @return [Boolean]
function classifier::evaluate_rule (
  Data $left,
  Classifier::Operators $operator,
  Data $right,
  Boolean $invert
) {
  $evaluated = case $operator {
    "==": {
      $left == $right
    }

    "=~": {
      $left =~ $right
    }

    ">": {
      versioncmp($left, $right) == 1
    }

    "=>": {
      versioncmp($left, $right) != -1
    }

    "<": {
      versioncmp($left, $right) == -1
    }

    "<=": {
      versioncmp($left, $right) != 1
    }

    default: {
      fail("Unknown operator ${operator}")
    }
  }

  if $invert {
    !$evaluated
  } else {
    $evaluated
  }
}
