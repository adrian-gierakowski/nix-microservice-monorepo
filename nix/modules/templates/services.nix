{ ... }:
{
  imports = [
    (import ./templates-factory.nix {
      name = "services";
      template = ./service.nix;
    })
  ];
}
