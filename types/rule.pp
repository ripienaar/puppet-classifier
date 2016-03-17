type Classifier::Rule = Struct[{
  fact     => String,
  operator => Classifier::Operators,
  value    => Data,
  invert   => Optional[Boolean]
}]
