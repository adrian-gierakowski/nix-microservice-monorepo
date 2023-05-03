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
    image = lib.mkOption {
      type = lib.types.package;
    };
    env = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = {};
    };
  };

  config._internal.passthru.config = {
    docker.images.${name}.image = config.image;

    kubernetes.resources.deployments.${name} = lib.mkMerge [
      (pkgs.kubelib.resources.deployment {
        inherit name;
        image = parentConfig.docker.images.${name}.path;
      })
      ({
        spec.template.spec.containers.default.env =
          builtins.mapAttrs
            (name: value: { inherit value; })
            config.env
          ;
      })
    ];
  };
}
