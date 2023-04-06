{
  environment = ["ABC=222"];
  log_length = 3000;
  log_level = "info";
  log_location = "./pc.log";
  processes = {
    __pc_log = {
      command = "tail -f -n100 process-compose-\${USER}.log";
      depends_on = {process0 = {condition = "process_completed";};};
      environment = ["REDACTED=1"];
      working_dir = "/tmp";
    };
    __pc_log_client = {
      command = "tail -f -n100 process-compose-\${USER}-client.log";
      working_dir = "/tmp";
    };
    _process2 = {
      availability = {restart = "on_failure";};
      command = "./test_loop.bash process2";
      environment = ["ABC=2221" "PRINT_ERR=111" "EXIT_CODE=2"];
      log_location = "./pc.proc2.log";
      readiness_probe = {
        failure_threshold = 3;
        http_get = {
          host = "google.com";
          scheme = "https";
        };
        initial_delay_seconds = 5;
        period_seconds = 5;
        success_threshold = 1;
        timeout_seconds = 2;
      };
      shutdown = {
        command = "sleep 2 && pkill -f 'test_loop.bash process2'";
        signal = 15;
        timeout_seconds = 4;
      };
    };
    bat_config = {command = "batcat -f process-compose.yaml";};
    kcalc = {
      command = "kcalc";
      disabled = true;
    };
    process0 = {
      command = "ls -lFa --color=always";
      working_dir = "/";
    };
    process1 = {
      availability = {
        backoff_seconds = 2;
        restart = "on_failure";
      };
      command = "./test_loop.bash \${PROC4}";
      depends_on = {
        _process2 = {condition = "process_completed_successfully";};
        process3 = {condition = "process_completed";};
      };
      environment = ["EXIT_CODE=0"];
      shutdown = {
        command = "sleep 2 && pkill -f process1";
        signal = 15;
        timeout_seconds = 4;
      };
    };
    process3 = {
      availability = {
        backoff_seconds = 2;
        restart = "always";
      };
      command = "./test_loop.bash process3";
      depends_on = {nginx = {condition = "process_healthy";};};
    };
    process4 = {
      command = "./test_loop.bash process4";
      disable_ansi_colors = true;
      environment = ["ABC=2221" "EXIT_CODE=4"];
      readiness_probe = {
        exec = {command = "ps -ef | grep -v grep | grep process4";};
        failure_threshold = 3;
        initial_delay_seconds = 5;
        period_seconds = 2;
        success_threshold = 1;
        timeout_seconds = 1;
      };
    };
  };
  shell = {
    shell_argument = "-c";
    shell_command = "zsh";
  };
  version = "0.5";
}
