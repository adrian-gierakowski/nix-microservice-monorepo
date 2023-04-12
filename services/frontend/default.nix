{ config, pkgs, lib, ... }:
let
  name = import ./name.nix;
  cfg = config.services.${name};
in
{
  services."${name}" = {
    package = pkgs.writers-extra.writeBashBinStrict name ''
      ${lib.getExe pkgs.fileshare} -p "$PORT" "$DATA_DIR"
    '';
    runtimeConfigType = lib.extra.mkSubmoduleOpts ({
      PORT = lib.types.port;
      DATA_DIR = lib.types.str;
    });
    runtimeConfig = { PORT = 8888; DATA_DIR = "./.data"; };
    dependsOn.randomness-service = {};
    # dependsOn.db.startOverride = true;
    # dependsOn.worker.startOverride = false;
    startDeps = true;
  };
}