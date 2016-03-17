type Classifier::Classification = Struct[{
  match    => Classifier::Matches,
  rules    => Array[Classifier::Rule],
  data     => Classifier::Data,
  classes  => Array[Classifier::Classname]
}]
