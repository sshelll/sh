#compdef passkeytool

_passkeytool_completions() {
  local -a commands
  commands=(
    "store:Store a new secret"
    "fetch:Fetch an existing secret"
    "delete:Delete an existing secret"
  )

  local curcontext="$curcontext" state line
  _arguments \
    '1: :->subcommand' \
    '*: :->args'

  case $state in
    subcommand)
      _describe -t commands 'passkeytool commands' commands
      ;;
  esac
}

compdef _passkeytool_completions passkeytool
