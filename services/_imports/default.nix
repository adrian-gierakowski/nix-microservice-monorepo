{ pkgs, ... }: {
  imports =
    # All imports shared between services should go here.
    (with pkgs.modules; [
      deploymentsForProcesses
      processes-with-process-compose
    ])
  ;
}
