{
  writers-extra,
  make-export-statements-from-json-object,
  name ? null
}@args:
let
  scriptName = "with-env-from-json";
  scriptDeps = with builtins; attrValues (removeAttrs args ["writers-extra" "name"]);
in
  writers-extra.mkBashScriptBinWithDeps
    scriptDeps
    (if name == null then scriptName else name)
    (./. + "/${scriptName}.sh")
