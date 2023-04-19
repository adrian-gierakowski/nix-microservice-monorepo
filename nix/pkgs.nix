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
      (self: super: { nix-filter = import sources.nix-filter; })
      # (self: super: { nixt = (import sources.nixt).default; })
      # Old version exported an overlay
      # (import sources.nixt)
      (self: super: { nix-test-runner = (import sources.nix-test-runner {}); })
      # Load all packages from ./packages, using filename as the name of the
      # pkgs attribute.
      (self: super: super.lib.extra.importPackagesFromDir self ./packages)
      # (self: super: { kubenix = (import /home/adrian/code/kubenix-hall-adrian).kubenix.${self.system}; })
      (import /home/adrian/code/kubenix-hall-adrian/default.nix).overlays.default
      # (import sources.kubenix).overlays.default
      (self: super: let inherit (super) lib; in {
        platformConfig = lib.extra.headOr {} (lib.extra.filterValue
          (name: value: !(
            # lib.extra.isIn name []
            # ||
            builtins.isFunction value
            ||
            lib.types.isOptionType value
          ))
          self.platform.config
        );
        platformConfigJSON = self.writers-extra.writeJSON
          { name = "platform-config-json"; }
          self.platformConfig
        ;
        # test = self.lib.evalModules { modules = []; };
        # platform = self.kubenix.evalModules {
        platform = self.lib.evalModules {
          specialArgs = {
            pkgs = self;
            inputs = { inherit sources; nix = self.nix;};
          };
          modules = [
            {
              config = {
                # _module.args.baseModules = modules;
                # _module.args.pkgsPath = self.lib.mkDefault self.path;
                _module.args.pkgs = self.lib.mkDefault self;
              };
            }
            # ({ kubenix, ... }: {
            #   imports = with kubenix.modules; [k8s];
            # })
            {
              imports = [
                ./../services
                ./modules/services.nix
                ./modules/process-compose.nix
              ];
              # config = {
              #   process-compose.default.config = {
              #     environment = ["A=b" "B=a"];
              #     processes = {
              #       echo = {
              #         package = self.writers.writeBashBin "my-process" ''
              #           echo A: $A, B: $B
              #         '';
              #         availability.restart = "always";
              #       };
              #     };
              #   };
              # };
            }
            # {
            #   config = {
            #     process-compose.default.config = {
            #       processes = {
            #         echo = {
            #           package = self.lib.mkForce (self.writers.writeBashBin "my-process" ''
            #             echo  A: $A, B: $B
            #           '') ;
            #         };
            #       };
            #     };
            #   };
            # }
          ];
        };
      })
    ]
    ++
    overlays
  ;
  pkgsPath = sources.nixpkgs;
in
  import pkgsPath { inherit config system; overlays = allOverlays; }
