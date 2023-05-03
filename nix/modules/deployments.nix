let
  thisModule = import ./_factories/template.nix {
    name = "deployments";
    template = ./deployment.nix;
    producesProps = ["docker" "kubernetes"];
  };
in
{ kubenix, ...}: {
  imports =
    [thisModule]
    ++
    (with kubenix.modules; [docker k8s])
  ;
}