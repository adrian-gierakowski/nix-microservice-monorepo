{ config, pkgs, lib, ... }:
let
  name = import ./name.nix;
  cfg = config.services.${name};
in
{
  services."${name}" = {
    package = pkgs.fileshare;
    runtimeConfigType = lib.extra.mkSubmoduleOpts ({
      PORT = lib.types.port;
      CONTENTS_PATH = lib.types.str;
    });
    runtimeConfig = { PORT = 8888; CONTENTS_PATH = "./.data"; };
    # dependsOn.init = {};
    # dependsOn.db.startOverride = true;
    # dependsOn.worker.startOverride = false;
    # startDeps = false;
  };
}