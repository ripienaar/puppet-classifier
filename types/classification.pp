type Classifier::Classification = Struct[{
  match    => Optional[Classifier::Matches],
  rules    => Array[Classifier::Rule],
  data     => Optional[Classifier::Data],
  classes  => Optional[Array[Classifier::Classname]]
}]
