{ config, pkgs, lib, ... }:
let
  name = import ./name.nix;
  cfg = config.processes.${name};
in
{
  processes."${name}" = {
    package = pkgs.writers-extra.writeBashBinStrict name ''
      write_to_path="$DATA_DIR/$WRITE_TO_FIILE_NAME"

      response=$(${lib.getExe pkgs.curl} -s http://$RANDOMNESS_SERVICE_HOST:$RANDOMNESS_SERVICE_PORT)
      >&2 echo "got response: $response"


      >&2 echo "writing to: $write_to_path"

      echo "$response" > "$write_to_path"
    '';
    runtimeConfigType = lib.extra.mkSubmoduleOpts ({
      INTERVAL_MS = lib.types.ints.positive;
      RANDOMNESS_SERVICE_HOST = lib.types.str;
      RANDOMNESS_SERVICE_PORT = lib.types.port;
      DATA_DIR = lib.types.str;
      WRITE_TO_FIILE_NAME = lib.types.str;
    });
    runtimeConfig = {
      INTERVAL_MS = 500;
      WRITE_TO_FIILE_NAME = "A";
      RANDOMNESS_SERVICE_HOST = config.processes.randomness-service.runtimeConfig.HOST;
      RANDOMNESS_SERVICE_PORT = config.processes.randomness-service.runtimeConfig.PORT;
      DATA_DIR = config.processes.frontend.runtimeConfig.DATA_DIR;
    };
  };
  processes.bash = { package = pkgs.bash; };
}