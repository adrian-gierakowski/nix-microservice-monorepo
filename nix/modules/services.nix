let
  thisModule = import ./_factories/template.nix {
    name = "services";
    template = ./service.nix;
    producesProps = ["kubernetes"];
  };
in
{ kubenix, ...}: {
  imports =
    [thisModule]
    ++
    (with kubenix.modules; [k8s])
  ;
}