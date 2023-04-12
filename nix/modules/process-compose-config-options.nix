{
	config,
	lib,
	pkgs,
  options,
	...
}:
# TODO: adde descriptions
let
	inherit (lib) mkOption;
  t = lib.types;
  # TODO: validate elem format
  environmentType = t.listOf t.str;
  submoduleWithOptions = options: t.submodule ({ inherit options; });
  environmentOption = mkOption {
    type = environmentType;
    default = [];
    example = ["ABC=2221" "PRINT_ERR=111" "EXIT_CODE=2"];
  };
  probeType = submoduleWithOptions {
    failure_threshold = mkOption {
      type = t.ints.unsigned;
      default = 3;
      example = 3;
    };
    http_get = mkOption {
      type = t.nullOr (submoduleWithOptions {
        host = mkOption {
          type = t.str;
          example = "google.com";
        };
        scheme = mkOption {
          type = t.str;
          default = "http";
          example = "http";
        };
        path = mkOption {
          type = t.str;
          default = "/";
          example = "/";
        };
        port = mkOption {
          type = t.port;
          example = "8080";
        };
      });
      default = null;
    };
    exec = mkOption {
      type = t.nullOr (submoduleWithOptions {
        command = mkOption {
          type = t.str;
          example = "ps -ef | grep -v grep | grep my-proccess";
        };
      });
      default = null;
    };
    initial_delay_seconds = mkOption {
      type = t.ints.unsigned;
      default = 0;
      example = 0;
    };
    period_seconds = mkOption {
      type = t.ints.unsigned;
      default = 10;
      example = 10;
    };
    success_threshold = mkOption {
      type = t.ints.unsigned;
      default = 1;
      example = 1;
    };
    timeout_seconds = mkOption {
      type = t.ints.unsigned;
      default = 3;
      example = 3;
    };
  };
  processType = t.submodule ({ config, ...}: { options = {
    availability = mkOption {
      type = t.nullOr (submoduleWithOptions {
        restart = mkOption {
          type = t.enum [
            "always"
            "on_failure"
            "exit_on_failure"
            "no"
          ];
          default = "no";
          example = "on_failure";
        };
        backoff_seconds = mkOption {
          type = t.ints.unsigned;
          default = 2;
          example = 2;
        };
        max_restarts = mkOption {
          type = t.ints.unsigned;
          default = 0;
          example = 0;
        };
      });
      default = null;
    };
    package = mkOption {
      type = t.nullOr t.package;
      default = null;
    };
    command = mkOption {
      type = t.str;
      default = if (config.package != null) then (lib.getExe config.package) else null;
      example = "./test_loop.bash process2";
    };
    disabled = mkOption {
      type = t.nullOr t.bool;
      default = null;
      example = true;
    };
    is_daemon = mkOption  {
      type = t.nullOr t.bool;
      default = null;
      example = true;
    };
    depends_on = mkOption {
      type = t.attrsOf (submoduleWithOptions {
        condition = mkOption {
          type = t.enum [
            "process_completed"
            "process_completed_successfully"
            "process_healthy"
            "process_started"
          ];
          example = "process_healthy";
        };
      });
      default = {};
    };
    disable_ansi_colors = mkOption {
      type = t.bool;
      default = false;
      example = true;
    };
    environment = environmentOption;
    log_location = mkOption {
      type = t.nullOr t.str;
      default = null;
      example = "./pc.my-proccess.log";
    };
    readiness_probe = mkOption {
      type = t.nullOr probeType;
      default = null;
    };
    liveness_probe = mkOption {
      type = t.nullOr probeType;
      default = null;
    };
    shutdown = mkOption {
      type = t.nullOr (submoduleWithOptions {
        command = mkOption {
          type = t.nullOr t.str;
          example = "sleep 2 && pkill -f 'test_loop.bash my-proccess'";
        };
        signal = mkOption {
          type = t.ints.unsigned;
          default = 15;
          example = 15;
        };
        timeout_seconds = mkOption {
          type = t.ints.unsigned;
          default = 10;
          example = 10;
        };
      });
      default = null;
    };
    working_dir = mkOption {
      type = t.nullOr t.str;
      default = null;
      example = "/tmp";
    };
  }; });
in
{
  options = {
    environment = environmentOption;
    log_length = mkOption {
      type = t.ints.unsigned;
      default = 1000;
      example = 3000;
    };
    log_level = mkOption {
      type = t.enum [
        "trace"
        "debug"
        "info"
        "warn"
        "error"
        "fatal"
        "panic"
      ];
      default = "info";
      example = "info";
    };
    log_location = mkOption {
      type = t.nullOr t.str;
      default = null;
      example = "./pc.log";
    };
    shell = mkOption {
      type = t.nullOr (submoduleWithOptions {
        shell_argument = mkOption {
          type = t.str;
          default = "-c";
          example = "-c";
        };
        shell_command = mkOption {
          type = t.str;
          default = lib.getExe pkgs.bash;
          example = "bash";
        };
      });
      default = null;
    };
    version = mkOption {
      type = t.str;
      default = "0.5";
      example = "0.5";
    };
    processes = mkOption {
      type = t.attrsOf processType;
      default = {};
    };
  };
}