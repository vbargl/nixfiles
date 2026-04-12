# Override carapace completer with CARAPACE_LENIENT to prevent errors
# on unknown flags and improve overall completion experience
let carapace_completer = {|spans: list<string>|
  # expand aliases
  let expanded_alias = (scope aliases | where name == $spans.0 | $in.0?.expansion?)
  let spans = (if $expanded_alias != null {
    $spans | skip 1 | prepend ($expanded_alias | split row " " | take 1)
  } else {
    $spans
  })

  CARAPACE_LENIENT=1 carapace $spans.0 nushell ...$spans
  | from json
  | default []
}

$env.config.completions.external.completer = $carapace_completer
