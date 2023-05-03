{
  config,
  kubenix,
  lib,
  name,
  pkgs,
  ...
}:
{
  imports = with kubenix.modules; [
    submodule
    docker
  ];

  # Args are used to pass information from the parent context.
  options.submodule.args = {
    image = lib.mkOption {
      # This is not just any package but package with imageName and imageTag
      # props, as produced by dockerTools.build(Layered)Image
      # TODO: make a specific type for it and move it to kubenix
      type = lib.types.package;
    };
    env = lib.mkOption {
      type = lib.types.attrsOf lib.types.string;
      default = {};
    };
  };

  config = {
    docker.images.${name}.image = config.submodule.args.image;

    submodule = {
      name = "deployment";
      passthru = {
        kubernetes.resources.deployments.${name} =
          pkgs.kubelib.resources.deployment {
            inherit name;
            image = config.docker.images.${name}.path;
          }
        ;
        kubernetes.resources.deployments.${name}.spec = {
          template.spec.containers.default.env = builtins.mapAttrs
            (name: value: { inherit value; })
            config.env
          ;
        };
        docker.images = config.docker.images;
      };
    };
  };
}
