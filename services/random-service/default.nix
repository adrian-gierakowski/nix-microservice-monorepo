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
    });
    runtimeConfig = { PORT = 9999; };
  };
}