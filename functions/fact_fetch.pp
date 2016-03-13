function classifier::fact_fetch (
  String $keys
) {
  $keys.split(/\./).reduce($facts) |$memo, $key| {
    if $memo !~ Undef {$memo[$key] }
  }
}
