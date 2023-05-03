{
  sources ? import ./sources.nix,
  config ? {},
  system ? builtins.currentSystem,
  overlays ? [],
}:
let
  allOverlays =
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
      (self: super: { modules = import ./modules; })
      (self: super: {
        helloImage = self.dockerTools.buildImage {
          name = "hello";
          created = "now";
          copyToRoot = self.buildEnv {
            name = "image-root";
            paths = [ self.hello ];
            pathsToLink = [ "/bin" ];
          };

          config.Cmd = [ "/bin/hello" ];
        };
      })
      # (import /home/adrian/code/kubenix-hall-adrian/default.nix).overlays.default
      (import sources.kubenix).overlays.default
      (self: super: let
        inherit (super) lib;
        removeEmptyAttrs = lib.converge (lib.filterAttrsRecursive (name: value: !(value == {})));
        sanitizeConfig = config: lib.pipe
          config
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
            (lib.extra.overPathIfExists ["kubernetes" "api"] (a: builtins.removeAttrs a ["definitions" "types" "_m" "_module"]))
            (lib.extra.overPathIfExists ["kubernetes" "api" "resources"] removeEmptyAttrs)
          ]
        ;
      in {
        testConfig = self.lib.evalModules { modules = [({ ... }@args: {
          options = {
            testOpt = self.lib.mkOption {
              type = self.lib.types.str;
              default = "1";
            };
          };
        })]; };
        platformTemplate = self.lib.makeExtensible (final: {
          baseModules = [
            {
              config = {
                # _module.args.baseModules = modules;
                # _module.args.pkgsPath = self.lib.mkDefault self.path;
                _module.args.pkgs = self.lib.mkDefault self;
              };
              options = {
                testOpt = self.lib.mkOption {
                  type = self.lib.types.str;
                  default = "1";
                };
              };
            }
            {
              imports = [
                ./../services
              ];
            }
          ];
          specialArgs = {
            pkgs = self;
            inputs = { inherit sources; nix = self.nix;};
          };
          extraModules = [];
          modules = final.baseModules ++ final.extraModules;
          evaled = self.kubenix.evalModules {
            inherit (final) specialArgs modules;
          };
          config = sanitizeConfig final.evaled.config;
          configJSON = self.writers-extra.writeJSON
            { name = "platform-config-json"; }
            self.platformConfig
          ;
        });
        platform.prd = self.platformTemplate;
        platform.dev = self.platformTemplate.extend (_:_:{
          extraModules = [
            { imports = [./../services/dev.nix]; }
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
