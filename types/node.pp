type Classifier::Node = Array[
  Struct[{
    "name"    => String,
    "classes" => Array[Classifier::Classname],
    "data"    => Classifier::Data
  }]
]
