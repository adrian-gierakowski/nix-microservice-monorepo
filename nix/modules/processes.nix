{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkOption;
  t = lib.types;
in
{
  options.processes = mkOption {
    type = t.attrsOf (t.submoduleWith {
      specialArgs.pkgs = pkgs;
      modules = [{ imports = [./process.nix]; }];
    });
    default = {};
  };
}