# 0.0.5
  * Add `has_ip_network` operator and add stdlib dependency
  * Remove `unpack_arrays` from the merge options as this function is being removed from Puppet
  * Fix bug where the classifications were not shown when debug is set
  * The `classes` key on a classification is now optional to allow for just exporting data in a rule
  * The `fact` key on a classification rule is now optional to allow for functions like `has_ip_network` where the left is pointless

# 0.0.4

  * Use Puppet 4.4.0 type aliases to improve readability and validate data at more places
  * Since Puppet 4.4.0 now supports deep interpolation of variables from hiera, remove restriction on facts being a fact only

# 0.0.3

  * Add a concept of arbitrary key value pairs on rules which are exposed as `$classification::data` post classification.  Set `data` in the rules.
  * Add a Environment Data Provider that expose the above data to hiera
