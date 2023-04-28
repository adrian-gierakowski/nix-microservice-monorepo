{
  config,
  kubenix,
  lib,
  # Name of submodule instance.
  name,
  # This is a shorthand for config.submodule.args and contains
  # final values of the args options.
  args,
  pkgs,
  ...
}:{
  imports = with kubenix.modules; [
    submodule
    k8s
  ];

  # Args are used to pass information from the parent context.
  options.submodule.args = {
    image = lib.mkOption {
      type = lib.types.str;
      default = name;
      # default = moduleArgs.docker.images.${name}.path;
    };
  };

  config = {
    submodule = {
      name = "deployment";
      passthru.testOpt = "1234";
      passthru.kubernetes.resources.deployments.${name} =
        pkgs.kubelib.resources.deployment {
          inherit name;
          image = args.image;
        };
    };
  };
}

# {
#   config,
#   kubenix,
#   lib,
#   # Name of submodule instance.
#   name,
#   # This is a shorthand for config.submodule.args and contains
#   # final values of the args options.
#   args,
#   ...
# }: {
#   imports = with kubenix.modules; [
#     # This needs to be imported in order to define a submodule.
#     submodule
#     # Importing this so that we can set config.kubernetes
#     # within the context of this submodule.
#     k8s
#   ];

#   # Args are used to pass information from the parent context.
#   options.submodule.args = {
#     image = lib.mkOption {
#       type = lib.types.str;
#       default = "";
#       # default = moduleArgs.docker.images.${name}.path;
#     };
#   };

#   config = {
#     submodule = {
#       name = "deployment";
#       passthru = {
#         kubernetes.objects = config.kubernetes.objects;
#         processes.package = pkgs.bash;
#       };
#     };

#     kubernetes = lib.mkMerge [
#       { namespace = name; }
#       { resources.namespaces.${name} = {}; }
#     ];
#   };
# }
