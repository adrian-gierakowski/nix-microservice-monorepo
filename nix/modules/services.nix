{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkOption;
  t = lib.types;
  cfg = config.services;
in
{
  imports = [
    ./process-compose.nix
  ];
  options.services = mkOption {
    type = t.attrsOf (t.submoduleWith {
      specialArgs.pkgs = pkgs;
      modules = [{ imports = [./service.nix]; }];
    });
  };
  config =
    let
      serviceNames = builtins.attrNames cfg;
      frontendDeps = cfg.frontend.depsToStart;
      collectServicesToStart = service:
        if service.depsToStart == []
        then [service]
        else [service] ++ (lib.concatMap
          (depName: collectServicesToStart cfg.${depName})
          service.depsToStart
        )
      ;
    in
    {
      process-compose = lib.genAttrs serviceNames (name:
        let
          # depsProcesses = lib.genAttrs cfg.${name}.depsToStart (depName: {
          #   package = cfg.${depName}.runWithEnv;
          #   availability.restart = "always";
          # });
          service = cfg.${name};
          allServicesToStart = collectServicesToStart service;
          pcConfigs = builtins.map (service: { config = service.process-compose.config; }) allServicesToStart;
        in lib.mkMerge pcConfigs
          #   {
          #     "${name}" = {
          #       package = cfg.${name}.runWithEnv;
          #       availability.restart = "always";
          #     };
          #   }
          #   // depsProcesses
          # ;
      );
    }
  ;
}