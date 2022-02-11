# hiera backend which can be used to retrieve variables from classifier::data
function classifier::hiera_backend(
  Variant[String, Numeric] $key,
  Hash                     $options,
  Puppet::LookupContext    $context,
) {
  if (!defined('$classifier::data')) {
    $context.not_found()
  }
  else {
    $data = $classifier::data

    if ($data and has_key($data, $key)) {
      $data[$key]
    }
    else {
      $context.not_found()
    }
  }
}
