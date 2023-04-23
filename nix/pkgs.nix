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
      (self: super: let
        inherit (super) lib;
        removeEmptyAttrs = lib.converge (lib.filterAttrsRecursive (name: value: !(value == {})));
      in {
        platformConfig = lib.pipe
          self.platform.config
          [
            (lib.extra.filterValue
              (name: value: (lib.isDerivation value) || !(
                # lib.extra.isIn name []
                # ||
                builtins.isFunction value
                ||
                lib.types.isOptionType value
            )))
            (lib.extra.headOr {})
            (lib.extra.overPathIfExists ["kubernetes" "api"] (a: builtins.removeAttrs a ["definitions" "types"]))
            (lib.extra.overPathIfExists ["kubernetes" "api" "resources"] removeEmptyAttrs)
          ]
        ;
        platformConfigJSON = self.writers-extra.writeJSON
          { name = "platform-config-json"; }
          self.platformConfig
        ;
        # test = self.lib.evalModules { modules = []; };
        platform = self.kubenix.evalModules {
        # platform = self.lib.evalModules {
          specialArgs = {
            pkgs = self;
            inputs = { inherit sources; nix = self.nix;};
            platformModules = {
              process = import ./modules/process.nix;
            };
          };
          modules = [
            {
              config = {
                # _module.args.baseModules = modules;
                # _module.args.pkgsPath = self.lib.mkDefault self.path;
                _module.args.pkgs = self.lib.mkDefault self;
              };
            }
            ({ kubenix, ... }: {
              imports = with kubenix.modules; [k8s];
              kubernetes.resources.deployments.my-deploy = self.kubelib.resources.deployment {
                name = "my-deploy";
                image = "image";
              };
            })
            ({ kubenix, ... }: {
              kubernetes.resources = self.kubelib.patches.exposeDeployment {
                name = "my-deploy";
              };
            })
            # {
            #   imports = [
            #     ./../services
            #     ./modules/processes-with-process-compose.nix
            #   ];
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
