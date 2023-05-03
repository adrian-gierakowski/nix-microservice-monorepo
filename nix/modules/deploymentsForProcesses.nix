let
  thisModule = import ./_factories/template.nix {
    name = "deploymentsForProcesses";
    template = ./deploymentForProcess.nix;
    producesProps = ["services" "deployments"];
  };
in
{
  imports = [
    thisModule
    ./deployments.nix
    ./services.nix
  ];
}