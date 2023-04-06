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
  options.process-compose = mkOption {
    type = types.attrsOf (types.submoduleWith {
      specialArgs.pkgs = pkgs;
      modules = [{ imports = [./process-compose-options.nix]; }];
    });
  };
}