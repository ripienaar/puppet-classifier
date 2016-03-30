# Emits a debug message when $classifier::debug is set
function classifier::debug (
  String $msg
) {
  if $::classifier::debug {
    notice($msg)
  }
}
