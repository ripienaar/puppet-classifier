type Classifier::Rule = Struct[{
  fact     => Optional[Data],
  operator => Classifier::Operators,
  value    => Data,
  invert   => Optional[Boolean]
}]
