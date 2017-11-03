# 0.1.0

  * Remove the old experimental hiera backend to improve compatibility with modern puppet (
  * Requires Puppet 5

# 0.0.11

  * Reverse the logic for the `in` expression to be more natural

# 0.0.10

  * Fix a syntax bug in 0.0.8 (Matteo Cerutti @m4ce)
  * Perform a deep merge on the calculated data (Matteo Cerutti @m4ce)

# 0.0.9

  * Add has_mac, has_ip_address and has_ip_netmask rule operators
  * Add in rule operator (Matteo Cerutti @m4ce)

# 0.0.8

  * Fix loading issues on recent puppet versions

# 0.0.7

  * Add an ENC to facilitate setting the environment
  * Support checking if the ENC classification was correctly applied
  * Log details about classification results when ENC is in use

# 0.0.6

  * Add the function `classifier::has_network_details` replacing the need for stdlib and old style facts
  * Fix debug logging of the classification rules before evaluation

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
