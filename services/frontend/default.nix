{ config, pkgs, lib, ... }:
let
  name = import ./name.nix;
  cfg = config.processes.${name};
in
{
  processes."${name}" = {
    package = pkgs.writers-extra.writeBashBinStrict name ''
      ${lib.getExe pkgs.fileshare} -p "$PORT" "$DATA_DIR"
    '';
    runtimeConfigType = lib.extra.mkSubmoduleOpts ({
      PORT = lib.types.port;
      DATA_DIR = lib.types.str;
    });
    runtimeConfig = lib.extra.allDefault {
      PORT = 8888;
      DATA_DIR = "./.data";
    };
    dependsOn.randomness-service = {};
  };
  deploymentsForProcesses.${name} = {};
}