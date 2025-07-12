#compdef otptool

_otptool_completions() {
  local -a commands
  commands=(
    "gen:Gen otp code from registered otp keys"
    "register:Register a new otp key"
    "delete:Delete an existing otp key"
  )

  local curcontext="$curcontext" state line
  _arguments \
    '1: :->subcommand' \
    '*: :->args'

  case $state in
    subcommand)
      _describe -t commands 'otptool commands' commands
      ;;
  esac
}

compdef _otptool_completions otptool
