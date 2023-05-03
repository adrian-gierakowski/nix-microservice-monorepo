{ ... }:
{
  imports = [
    (import ./templates-factory.nix {
      name = "deploymentsForProcesses";
      template = ./deploymentForProcess.nix;
      optsToSetExtra = [
        "deployments"
        "services"
      ];
    })
  ];
}
