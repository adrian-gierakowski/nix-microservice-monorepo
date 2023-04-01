let
  pkgs = import ./nix/pkgs.nix {};
in with pkgs; mkShell {
	packages = [nodejs fileshare niv process-compose jq];
}
