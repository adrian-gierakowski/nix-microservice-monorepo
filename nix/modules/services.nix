{
	config,
	lib,
	pkgs,
	...
}:
let
	inherit (lib) types mkOption;
in
{
  options.services = mkOption {
    type = types.attrsOf (types.submodule ./service.nix);
  };
}