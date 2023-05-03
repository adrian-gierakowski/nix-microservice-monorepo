{
  config,
  kubenix,
  lib,
  # Name of submodule instance.
  name,
  # This is a shorthand for config.submodule.args and contains
  # final values of the args options.
  args,
  ...
}: {
  imports = with kubenix.modules; [
    # This needs to be imported in order to define a submodule.
    submodule
  ];

  # Args are used to pass information from the parent context.
  options.submodule.args = {
    str = lib.mkOption {
      type = lib.types.str;
      default = "";
    };
  };

  config = {
    submodule = {
      name = "simple-kubenix-submodule";
      passthru = {
        testOpt = args.str;
      };
    };
  };
}
