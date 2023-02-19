{ config, pkgs, lib, ... }:
let
  cfg = config.services.frontend;
in
{
  services.frontend = {
    package = pkgs.fileshare;
    runtimeConfigType = lib.extra.mkSubmoduleOpts ({
      PORT = lib.types.port;
    });
    runtimeConfig = { PORT = 8888; };
    dependsOn.init = {};
    dependsOn.db.startOverride = true;
    dependsOn.worker.startOverride = false;
    startDeps = false;
  };
}