class classifier (
  Array[Pattern[/\A([a-z][a-z0-9_]*)?(::[a-z][a-z0-9_]*)*\Z/]] $classes = [],
  Hash[String,
    Struct[{
      match => Enum["all", "any"],
      rules    => Array[
        Struct[{
          fact     => String,
          operator => Enum["==", "=~", ">", " =>", "<", "<="],
          value    => Data,
          invert   => Optional[Boolean]
        }]
      ],
      classes  => Array[Pattern[/\A([a-z][a-z0-9_]*)?(::[a-z][a-z0-9_]*)*\Z/]]
    }]
  ] $rules = {}
) {
  (classifier::classify($rules) + $classes).include
}
