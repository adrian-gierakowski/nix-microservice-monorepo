{ ... }:
{
  imports = [
    (import ./templates-factory.nix {
      name = "deployments";
      template = ./deployment.nix;
    })
  ];
}
