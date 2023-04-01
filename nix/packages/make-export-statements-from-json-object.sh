#!/usr/bin/env bash
set -ueo pipefail

# Outputs following line for each key\value pair in given json object:
# export 'KEY_NAME'="${KEY_NAME-$(echo 'VALUE')}"
#
# Note the '' around first KEY_NAME and VALUE which prevent script injection.
# The @sh jq function also escapes any single quotes within the quoted string.
# The second KEY_NAME does not need to be quoted since shell will throw if
# it's not a valid identifier, however "" around the entire expression after
# = are needed in case KEY_NAME env var is set at the time of the evaluation
# of the export statement to prevent IFS based splitting.
make_export_statements () {
  jq -r 'to_entries
    | map(
        "export "
        + @sh "\(.key)="
        + "\"${\(.key)-$(echo "
        + @sh "\(.value|tostring)"
        + ")}\""
      )
    |.[]' "${@}"
}

if [[ -n ${1:-} ]]
  then
    if [[ -f "$1" ]]
    then
      make_export_statements "$1"
    else
      echo "$1" | make_export_statements
    fi
  # expects input to be piped in
  else make_export_statements
fi
