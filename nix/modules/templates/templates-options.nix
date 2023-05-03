{
  lib,
  ...
}:
{
  options.templates.names = lib.mkOption {
    type = lib.types.listOf lib.types.str;
    default = [];
  };
  config.templates.names = ["deployments" "services"];
}