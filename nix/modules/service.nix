{
	config,
	lib,
	name,
	pkgs,
  options,
	...
}:
let
	inherit (lib) types mkOption;
in
{
  options.package = mkOption {
    type = types.package;
  };
  options.exe = mkOption {
    type = types.path;
    default = lib.getExe config.package;
  };
  options.runtimeConfigType = mkOption {
    type = types.anything;
    default = types.attrsOf (types.nullOr types.str);
  };
  options.runtimeConfig = mkOption {
    type = config.runtimeConfigType;
    default = {};
  };
  options.runtimeConfigToEnv = mkOption {
    type = types.functionTo (types.attrsOf types.str);
    default = attrs:
      let nonNullAttrs = lib.filterAttrs (n: v: n != null) attrs;
      in lib.extra.attrsToAttsOfJsonStrings attrs;
  };
  options.runtimeEnv = mkOption {
    type = types.attrsOf types.str;
    default = config.runtimeConfigToEnv config.runtimeConfig;
  };
  # options.runtimeEnvJson = mkOption {
  #   type = types.str;
  #   default = lib.filterAttrs (n: v: n != null) config.runtimeConfig;
  # };
}