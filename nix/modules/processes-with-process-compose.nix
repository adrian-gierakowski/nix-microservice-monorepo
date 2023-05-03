{
  config,
  lib,
  ...
}:
let
  inherit (config) processes;
  # TODO: move to lib
  processComposeProcessConfig = processConfig: {
    package = processConfig.runWithEnv;
    availability.restart =
      if processConfig.type == "job"
      # Assuming a job needs to be completed successfully and if
      # it fails then there is no way to recover.
      then "exit_on_failure"
      else "always"
    ;
    depends_on = lib.genAttrs processConfig.depsToStart (depName: {
      condition = processConfig.dependsOn.${depName}.condition;
    });
  };
  serviceNames = builtins.attrNames processes;
  allProcessComposeProcesses = builtins.mapAttrs
    (name: value: processComposeProcessConfig value)
    processes
  ;
  processComposeCofigsForProcesses = processConfigs:
    let
      collectProcessConfigs = name:
        let
          service = processConfigs.${name};
          deps = builtins.concatMap
            (depName: collectProcessConfigs depName)
            service.depsToStart
          ;
        in
          [{ inherit name; value = processComposeProcessConfig service; }] ++
          deps
      ;
      serviceNames = builtins.attrNames processConfigs;
    in lib.genAttrs
      serviceNames
      (name:
        let processes = builtins.listToAttrs (collectProcessConfigs name);
        in { config.processes = processes; })
  ;
  configsPerProcess = processComposeCofigsForProcesses processes;
in
{
  imports = [
    ./process-compose.nix
    ./processes.nix
  ];
  config = lib.mkMerge [
    { process-compose = configsPerProcess; }
    { process-compose.all.config.processes = allProcessComposeProcesses; }
  ];
}