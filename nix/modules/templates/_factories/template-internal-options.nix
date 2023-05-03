{ producesProps }:
{
  lib,
  ...
}:
let
  passthruPropType = lib.mkOption {
    type = lib.types.attrs;
  };
in
{
  options = {
    _internal.passthru = {
      config = lib.genAttrs producesProps (_: passthruPropType);
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
      };
    };
  };
}
