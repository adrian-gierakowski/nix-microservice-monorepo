{
  lib,
  ...
}:
{
  options = {
    _internal.passthru = {
      config = lib.mkOption {
        type = lib.types.attrs;
      };
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
      };
    };
  };
}
