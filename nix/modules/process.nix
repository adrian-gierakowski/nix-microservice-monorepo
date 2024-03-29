{
	config,
	lib,
	name,
	pkgs,
	...
}:
let
	inherit (lib) mkOption;
  t = lib.types;
  depConditionDescriptions = {
    process_completed = "is the type for waiting until a process has completed (any exit code)";
    process_completed_successfully = "is the type for waiting until a process has completed successfully (exit code 0)";
    process_healthy = "is the type for waiting until a process is healthy";
    process_started = "is the type for waiting until a process has started (default)";
  };
  dependsOnType = t.submodule {
    options = {
      startOverride = mkOption {
        type = t.nullOr t.bool;
        default = null;
        description = ''
          Whether the dependency should be started when this service starts.
          If null, then value of startDeps will be used.
        '';
      };
      condition = mkOption {
        type = t.enum (builtins.attrNames depConditionDescriptions);
        default = "process_started";
        description = ''
          Aequired state the dependency needs to reach in order for dependant to start.
          One of:
          ${builtins.mapAttrs (k: v: "- ${k}: ${v}")}
          see: https://github.com/F1bonacc1/process-compose#-define-process-dependencies
        '';
      };
    };
  };
in
{
  options = {
    type = mkOption {
      type = t.enum [
        "server"
        "worker"
        "job"
        "cronJob"
      ];
      default = "server";
      description = ''
        Process type:
        - server: runs continuously and exposes an API which can be used to contact it from outside
        - worker: runs continuously but cannot be contacted from outside
        - job: runs once
        - cronJob: runs on a schedule
      '';
    };
    name = mkOption {
      type = t.str;
      default = name;
    };
    package = mkOption {
      type = t.package;
    };
    exe = mkOption {
      type = t.path;
      default = lib.getExe config.package;
    };
    runWithEnv = mkOption {
      type = t.package;
      default = pkgs.writers-extra.writeBashBinStrict "${name}-run-with-env" ''
        exec ${lib.getExe config.withRuntimeEnv} \
          ${config.exe} \
          "''${@}"
      '';
    };
    runtimeConfigType = mkOption {
      type = t.optionType;
      default = t.attrsOf (t.nullOr t.str);
    };
    runtimeConfig = mkOption {
      type = config.runtimeConfigType;
      default = {};
    };
    runtimeConfigToEnv = mkOption {
      type = t.functionTo (t.attrsOf t.str);
      default = lib.extra.attrsToAttsOfJsonStrings;
    };
    runtimeEnv = mkOption {
      type = t.attrsOf t.str;
      default = config.runtimeConfigToEnv config.runtimeConfig;
    };
    runtimeEnvJsonStr = mkOption {
      type = t.str;
      default = builtins.toJSON config.runtimeEnv;
    };
    withRuntimeEnv = mkOption {
      type = t.package;
      default = pkgs.writers-extra.writeBashBinStrict "${name}-with-runtime-env" ''
        exec ${lib.getExe pkgs.with-env-from-json} \
          ${builtins.toFile "${name}-runtime-env" config.runtimeEnvJsonStr} \
          "''${@}"
      '';
    };
    dependsOn = mkOption {
      type = t.attrsOf dependsOnType;
      default = {};
    };
    startDeps = mkOption {
      type = t.bool;
      default = true;
      description = "Whether dependencies should be started when this service starts.";
    };
    depsToStart = mkOption {
      type = t.listOf t.str;
      description = "List of deps to start when this service starts, calculated based on dependsOn.<dep>.startOverride and startDeps.";
      default =
        let
          depNames = builtins.attrNames config.dependsOn;
          shouldStart = depName:
            let
              startOverride = config.dependsOn.${depName}.startOverride;
            in
              if startOverride == null then config.startDeps else startOverride
          ;
        in
          builtins.filter shouldStart depNames
      ;
    };
  };
}