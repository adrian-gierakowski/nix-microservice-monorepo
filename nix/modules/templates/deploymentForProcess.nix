{
  config,
  lib,
  name,
  pkgs,
  parentConfig,
  ...
}:
let
  process = parentConfig.processes.${name};
in {
  options = {
    isWorker = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
    runtimeConfigPortVarName = lib.mkOption {
      type = lib.types.str;
      default = "PORT";
    };
    # TODO: custom buildImage function
  };

  config._internal.passthru.config = {
    deployments.${name} = {
      # TODO: use buildLayeredImage by default
      image = pkgs.dockerTools.buildImage {
        inherit name;
        copyToRoot = pkgs.buildEnv {
          name = "image-root";
          paths = with pkgs.dockerTools; [
            # usrBinEnv
            # binSh
            caCertificates
            fakeNss
          ];
          pathsToLink = [ "/bin" "/etc" "/var" ];
        };

        config.Cmd = [ process.exe ];
      };
      env = process.runtimeEnv;
    };
    services = if config.isWorker
      then {}
      else {
        "${name}" =
          let
            portVarName = config.runtimeConfigPortVarName;
            ifPortInConfig = lib.mkIf (process.runtimeConfig ? "${portVarName}");
          in {
            containerPort = ifPortInConfig process.runtimeConfig.${portVarName};
            containerPortEnvName = ifPortInConfig null;
          }
        ;
      }
    ;
  };
}
