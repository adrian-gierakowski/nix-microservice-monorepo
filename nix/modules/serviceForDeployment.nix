{
  config,
  kubenix,
  lib,
  name,
  pkgs,
  parentConfig,
  ...
}:
{
  imports = with kubenix.modules; [
    submodule
  ];

  # Args are used to pass information from the parent context.
  options.submodule.args = {
    port = lib.mkOption {
      type = lib.types.port;
      default = 80;
    };
    containerPort = lib.mkOption {
      type = lib.types.port;
      default = 8080;
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

  config = {
    submodule = {
      name = "serviceForDeployment";
      passthru.kubernetes.resources = pkgs.kubelib.patches.exposeDeployment {
        inherit name;
        inherit (config.submodule.args)
          port
          containerPort
          containerPortName
          containerName
          type
        ;
        selector = parentConfig.kubernetes.api.resources.deployments.${name}.spec.template.metadata.labels;
      };
    };
  };
}
