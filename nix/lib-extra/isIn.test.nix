let
  pkgs = import ../pkgs.nix {};
  inherit (pkgs) lib;
  inherit (lib.extra) isIn;
in lib.extra.prependPrefixToAttrNames "test" {
  "true" = {
    expr = isIn "a" ["a" "b"];
    expected = true;
  };
  "false" = {
    expr = isIn "a" ["_" "b"];
    expected = false;
  };
}