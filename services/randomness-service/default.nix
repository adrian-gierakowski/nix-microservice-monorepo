{ config, pkgs, lib, ... }:
let
  name = import ./name.nix;
  package = import ./package.nix;
in
{
  processes."${name}" = {
    package = pkgs.callPackage package { inherit name; };
    runtimeConfigType = lib.extra.mkSubmoduleOpts ({
      PORT = lib.types.port;
      HOST = lib.types.str;
    });
    runtimeConfig = {
      PORT = 9999;
      HOST = "localhost";
    };
    dependsOn.workerA = {};
  };
  deploymentsForProcesses.${name} = {};
}