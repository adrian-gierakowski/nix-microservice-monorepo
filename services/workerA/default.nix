{ config, pkgs, lib, ... }:
let
  name = import ./name.nix;
  cfg = config.services.${name};
in
{
  services."${name}" = {
    package = pkgs.writers.writeBashBin name ''
      ${lib.getExe pkgs.curl} http://$RANDOMNESS_SERVICE_HOST:$RANDOMNESS_SERVICE_PORT
    '';
    runtimeConfigType = lib.extra.mkSubmoduleOpts ({
      INTERVAL_MS = lib.types.ints.positive;
      RANDOMNESS_SERVICE_HOST = lib.types.str;
      RANDOMNESS_SERVICE_PORT = lib.types.port;
    });
    runtimeConfig = {
      INTERVAL_MS = 500;
      RANDOMNESS_SERVICE_HOST = config.services.randomness-service.runtimeConfig.HOST;
      RANDOMNESS_SERVICE_PORT = config.services.randomness-service.runtimeConfig.PORT;
    };
  };
}