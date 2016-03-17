# 0.0.4

  * Use Puppet 4.4.0 type aliases to improve readability and validate data at more places
  * Since Puppet 4.4.0 now supports deep interpolation of variables from hiera, remove restriction on facts being a fact only

# 0.0.3

  * Add a concept of arbitrary key value pairs on rules which are exposed as `$classification::data` post classification.  Set `data` in the rules.
  * Add a Environment Data Provider that expose the above data to hiera
