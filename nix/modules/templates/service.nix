{
  config,
  lib,
  name,
  pkgs,
  parentConfig,
  ...
}:
{
  options = {
    port = lib.mkOption {
      type = lib.types.port;
      default = 80;
    };
    containerPort = lib.mkOption {
      type = lib.types.port;
      default = 8080;
    };
    containerPortEnvName = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = "PORT";
    };
    containerPortName = lib.mkOption {
      type = lib.types.str;
      default = "default";
    };
    containerName = lib.mkOption {
      type = lib.types.str;
      default = "default";
    };
    type = lib.mkOption {
      type = lib.types.enum [
        "ExternalName"
        "ClusterIP"
        "NodePort"
        "LoadBalancer"
      ];
      default = "ClusterIP";
    };
  };

  config._internal.passthru.config.kubernetes.resources =
    pkgs.kubelib.patches.exposeDeployment {
      inherit name;
      inherit (config)
        port
        containerPort
        containerPortName
        containerPortEnvName
        containerName
        type
      ;
      selector = parentConfig.kubernetes
        .api.resources.deployments.${name}
        .spec.template.metadata.labels
    ;
  };
}
