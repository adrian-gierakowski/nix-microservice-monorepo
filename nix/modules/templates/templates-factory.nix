{
  name,
  template,
  optsToOmitExtra ? [],
  optsToSetExtra ? [],
  passthruWhitelist ? [],
}:
{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) types mkOption;
in
{
  imports = [
    # ./templates-options.nix
    (import ./templates-base-factory.nix { inherit
      name
      optsToOmitExtra
      passthruWhitelist
      optsToSetExtra;
    })
  ];
  options.templates."${name}" = mkOption { type = lib.types.str; default = name; };

  options."${name}" = mkOption {
    type = types.attrsOf (types.submoduleWith {
      specialArgs = {
        pkgs = pkgs;
        parentConfig = config;
      };
      modules = [
        ./template-base.nix
        template
      ];
    });
    default = {};
  };
}