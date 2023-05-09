{
  lib,
  jq,
  writers-extra,
  name ? "jq-paths"
}:
writers-extra.writeBashBinStrict
  name
  ''
  # path logic inspired by https://github.com/stedolan/jq/issues/243

  ${lib.getExe jq} -r '
  [
    path(..)  |
    map(
      # use generic object index syntax if key contains non-alphanumeric characters or starts with a digit
      select(type == "string" and (test("[^a-zA-Z0-9_]") or test("^[0-9]"))) |= "[\"" + . + "\"]"
    ) |
    map(
      # numbers are assumed to be array indexes only
      select(type == "number") |= "[]"
    ) | join(".")
  ] | sort | unique | .[] | split(".[") | join("[") | "." + .
  '
  ''
