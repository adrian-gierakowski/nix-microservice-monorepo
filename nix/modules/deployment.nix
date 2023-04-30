{
  config,
  kubenix,
  lib,
  # Name of submodule instance.
  name,
  # This is a shorthand for config.submodule.args and contains
  # final values of the args options.
  pkgs,
  # docker,
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
      type = lib.types.package;
      default = pkgs.helloImage.image;
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
        docker.images = config.docker.images;
      };
    };
  };
}
