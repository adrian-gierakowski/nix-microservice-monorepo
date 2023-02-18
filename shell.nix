let
  pkgs = import ./nix/pkgs.nix {};
in with pkgs; mkShell {
	packages = [fileshare];
}
