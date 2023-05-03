{
  name,
  template,
  producesProps,
}:
{
  config,
  lib,
  specialArgs,
  ...
}:
let
  inherit (lib) types mkOption;
in
{
  imports = [
    (import ./template-config.nix {
      inherit
        name
        producesProps
      ;
    })
  ];

  options."${name}" = mkOption {
    type = types.attrsOf (types.submoduleWith {
      specialArgs =
        { parentConfig = config; }
        # Inherit specialArgs from parent.
        // specialArgs
      ;
      modules = [
        (import ./template-internal-options.nix { inherit producesProps; })
        template
      ];
    });
    default = {};
  };
}