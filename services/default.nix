{ pkgs, ... }: {
  imports =
    # All imports shared between services should go here.
    (with pkgs.kubelib.templates; [
      deploymentsForProcesses
    ])
    ++
    [
      ./frontend
      ./randomness-service
      ./workerA
    ]
  ;
}
