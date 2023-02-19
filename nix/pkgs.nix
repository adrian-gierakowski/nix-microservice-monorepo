{
  sources ? import ./sources.nix,
  config ? {},
  system ? builtins.currentSystem,
  overlays ? []
}:
let
  allOverlays =
    # These overlays augment centrally defined packages with things specific
    # to this service.
    [
      (self: super: { lib = super.lib.extend (lib: _: { extra = import ./lib-extra { inherit lib; }; }); })
      (self: super: { nix-filter = import (import ./sources.nix).nix-filter; })
      (self: super: { kubenix = super.callPackage (import sources.kubenix) {}; })
      (self: super: {
        platform = (self.kubenix.evalModules {
          modules = (import ./../services) ++ [
            (import ./modules/services.nix)
        #     ({ pkgs, lib, ... }: {
        #       config.services.server2.package = pkgs.fileshare;
        #       config.services.server2.runtimeConfigType =
        #         let inherit (lib) extra types mkOption;
        #         # mkSubmoduleOpts allows for quick prototyping of nested
        #         # options.
        #         in with types; extra.mkSubmoduleOpts ({
        #           # This is converted to: mkOption { type = str; }
        #           # by mkSubmoduleOpts helper.
        #           string = str;
        #           # In order to add default, description etc, we need
        #           # to use: mkOption { type: ..., }
        #           # which is more verbose but preferred long term
        #           int = mkOption {
        #             type = int;
        #             default = 1;
        #             description = "config prop of type int";
        #           };
        #           array = listOf int;
        #           obj = extra.mkSubmoduleOpts ({
        #             A = int;
        #             B = str;
        #           });
        #         })
        #       ;
        #       # Same as above but with explicit calls to submodule and mkOption
        #       # NOTE: submodule props need to be nested unter `options`
        #       # config.services.server2.runtimeConfigType =
        #       #   let inherit (lib) types mkOption;
        #       #   in with types; submodule ({
        #       #     options = {
        #       #       int = mkOption { type = int; };
        #       #       string = mkOption { type = str; };
        #       #       array = mkOption { type = listOf int; };
        #       #       obj = mkOption {
        #       #         type = submodule ({
        #       #           options = {
        #       #             A = mkOption { type = int; };
        #       #             B = mkOption { type = str; };
        #       #           };
        #       #         });
        #       #       };
        #       #     };
        #       #   })
        #       # ;
        #       config.services.server2.runtimeConfig = {
        #         int = 1;
        #         string = "A";
        #         array = [1 2 3];
        #         obj = { A = 1; B = "C"; };
        #       };
        #     })
          ];
        });
      })
    ]
    ++
    overlays
  ;
  pkgsPath = sources.nixpkgs;
in
  import pkgsPath { inherit config system; overlays = allOverlays; }
