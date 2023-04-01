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
      RANDOM_RANGE_MAX = lib.types.numbers.positive;
    });
    runtimeConfig = { PORT = 9999; RANDOM_RANGE_MAX = 1; };
  };
}