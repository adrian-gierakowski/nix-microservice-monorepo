{
  config,
  lib,
  pkgs,
  inputs,
  ...
}@args:
let
  inherit (lib) types mkOption;
  devenvModules = inputs.sources.devenv + /src/modules;
in
{
  options.devenv = mkOption {
    type = types.submoduleWith {
      modules = [
        (devenvModules + "/top-level.nix")
        {
          disabledModules = []
            ++ (lib.extra.listDirEntries (devenvModules + "/integrations"))
            ++ (lib.extra.listDirEntries (devenvModules + "/languages"))
          ;
          devenv.cliVersion = "0.5.1";
          devenv.warnOnNewVersion = false;
        }
      ];
      specialArgs = { inherit pkgs inputs; };
      shorthandOnlyDefinesConfig = true;
    };
    default = {};
  };
}