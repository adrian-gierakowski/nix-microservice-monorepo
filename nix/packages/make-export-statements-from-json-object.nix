{
  jq,
  writers-extra,
  name ? null
}@args:
let
  scriptName = "make-export-statements-from-json-object";
  scriptDeps = with builtins; attrValues (removeAttrs args ["writers-extra" "name"]);
in
  writers-extra.mkBashScriptBinWithDeps
    scriptDeps
    (if name == null then scriptName else name)
    (./. + "/${scriptName}.sh")
