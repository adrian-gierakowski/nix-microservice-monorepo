{ config, pkgs, lib, ... }:
let
  name = import ./name.nix;
  cfg = config.services.${name};
in
{
  services."${name}" = {
    package = pkgs.writers.writeBashBin name ''
      ${lib.getExe pkgs.fileshare} -p "$PORT" "$DATA_DIR"
    '';
    runtimeConfigType = lib.extra.mkSubmoduleOpts ({
      PORT = lib.types.port;
      DATA_DIR = lib.types.str;
    });
    runtimeConfig = { PORT = 8888; DATA_DIR = "./.data"; };
    # dependsOn.init = {};
    # dependsOn.db.startOverride = true;
    # dependsOn.worker.startOverride = false;
    # startDeps = false;
  };
}