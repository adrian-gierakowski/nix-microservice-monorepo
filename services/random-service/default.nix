{ config, pkgs, lib, ... }:
let
  name = import ./name.nix;
  cfg = config.services.${name};
  package = import ./package.nix;
in
{
  services."${name}" = {
    package = pkgs.callPackage package { inherit name; };
    runtimeConfigType = lib.extra.mkSubmoduleOpts ({
      PORT = lib.types.port;
      A = lib.types.str;
    });
    runtimeConfig = { PORT = 9999; A = "bla"; };
  };
}