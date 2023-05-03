{
  name,
  optsToOmit ? ["_module" "_m" "submodules" "templates" name],
  optsToOmitExtra ? [],
  optsToSetExtra ? [],
  passthruWhitelist ? [],
}:
{
  config,
  lib,
  options,
  ...
}:
let
  allTemplateNames = builtins.attrNames options.templates;
  optionsToOmit = optsToOmit ++ optsToOmitExtra ++ allTemplateNames;
  optionNames = if passthruWhitelist != []
    then passthruWhitelist
    else
      (builtins.attrNames (removeAttrs options optionsToOmit))
      ++ optsToSetExtra
  ;
  templateInstances = builtins.attrValues config.${name};
  getPassthruDefsForOptName = name: map
    (x: x._internal.passthru.config.${name})
    (builtins.filter
      (x: x._internal.passthru.enable && x._internal.passthru.config ? ${name})
      templateInstances
    )
  ;
  passthruConfigs = map
    (name: { "${name}" = lib.mkMerge (getPassthruDefsForOptName name); })
    optionNames
  ;
in {
  config = lib.mkMerge passthruConfigs;
}