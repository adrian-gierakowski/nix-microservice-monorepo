{
	config,
	lib,
	pkgs,
  options,
  name ? "",
	...
}:
# TODO: adde descriptions
let
	inherit (lib) mkOption;
  t = lib.types;
  makeInfix = str: if str == "" then "-" else "-${str}-";
in
{
  options = {
    config = mkOption {
      type = t.submoduleWith {
        specialArgs.pkgs = pkgs;
        modules = [{ imports = [./process-compose-config-options.nix]; }];
      };
    };
    configFile = mkOption {
      type = t.package;
      default = pkgs.writers-extra.writeJSON { name = "pc${makeInfix config.name}config"; } config.config;
    };
    name = mkOption {
      type = t.str;
      default = name;
    };
    package = mkOption {
      type = t.package;
      default = pkgs.process-compose;
    };
    runPackage = mkOption {
      type = t.package;
    };
    run = mkOption {
      type = t.path;
    };
  };
  config = {
    runPackage = pkgs.writers-extra.writeBashBinStrict "pc${makeInfix config.name}run" ''
      exec ${lib.getExe config.package} -f ${config.configFile}
    '';
    run = lib.getExe config.runPackage;
  };
}