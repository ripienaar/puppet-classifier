# Checks if interface details match a given string
#
# This will iterate all the known network interfaces
# and fetch their IPv4 and IPv6 details and match against
# them
#
# @example checks if an ip exist
#   has_interface_detail("192.168.88.11")            => true
#   has_interface_detail("fe80::20c:29ff:fece:f8ec") => true
#
# @example checks if a network exist
#   has_interface_detail("192.168.88.0", "network") => true
#
# @param $match [String] an ip or network to match against
# @param $what [Enum["address", "network"]] what to check
# @return [Boolean]
function classifier::has_interface_detail (
  String $match,
  Enum["address", "network"] $what="address"
) {
  $ips = $facts["networking"]["interfaces"].map |$iname, $interface| {
    ["bindings", "bindings6"].map |$bname| {
      $interface[$bname].map |$binding| {
        $binding[$what]
      }
    }
  }.flatten

  $match in $ips
}
