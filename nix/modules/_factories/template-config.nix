{
  name,
  producesProps,
}:
{
  config,
  lib,
  options,
  ...
}:
let
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
    producesProps
  ;
in {
  config = lib.mkMerge passthruConfigs;
}