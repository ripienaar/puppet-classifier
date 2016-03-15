class classifier (
  Hash[String,
    Struct[{
      match    => Enum["all", "any"],
      rules    => Array[
        Struct[{
          fact     => String,
          operator => Enum["==", "=~", ">", " =>", "<", "<="],
          value    => Data,
          invert   => Optional[Boolean]
        }]
      ],
      data       => Optional[Hash[Pattern[/\A([a-z][a-z0-9_]*)?(::[a-z][a-z0-9_]*)*\Z/], Data]],
      classes    => Array[Pattern[/\A([a-z][a-z0-9_]*)?(::[a-z][a-z0-9_]*)*\Z/]]
    }]
  ] $rules = {},
  Array[Pattern[/\A([a-z][a-z0-9_]*)?(::[a-z][a-z0-9_]*)*\Z/]] $extra_classes = [],
  Boolean $debug = false
) {
  class{"classifier::classify":
    rules => $rules,
    debug => $debug
  }

  $classification = $classifier::classify::classification
  $classification_classes = $classifier::classify::classification_classes
  $data = $classifier::classify::data
  $classes = $classification_classes + $extra_classes

  class{"classifier::apply":
    classes => $classes,
    debug   => $debug
  }
}
