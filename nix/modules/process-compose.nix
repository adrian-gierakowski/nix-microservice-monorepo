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
  options.process-compose = mkOption {
    type = t.attrsOf (t.submoduleWith {
      specialArgs.pkgs = pkgs;
      shorthandOnlyDefinesConfig = true;
      modules = [{ imports = [./process-compose-options.nix]; }];
    });
  };
}