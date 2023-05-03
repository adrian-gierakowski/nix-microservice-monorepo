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
              options = {
                testOpt = self.lib.mkOption {
                  type = self.lib.types.str;
                  default = "1";
                };
              };
              # options = {
              #   kubernetes = self.lib.mkOption {
              #     type = self.lib.types.attrs;
              #     default = {};
              #   };
              # };
            }
            ({ kubenix, config, ... }: {
              imports =
                [
                  ./modules/templates/templates-options.nix
                ]
                ++
                (with kubenix.modules; [
                  # submodules
                  k8s
                  docker
                ])
                ++
                (with self.kubelib.templates; [
                  deployments
                  # services
                  ./modules/templates/deployments2.nix
                  # deploymentsForProcesses
                ])
                # ++
                # [{
                #   options.templates.names = self.lib.mkOption {
                #     type = self.lib.types.listOf self.lib.types.str;
                #     default = [];
                #   };
                # }]
              ;

              # # Import submodule.
              # submodules.imports = [
              #   ./modules/simple-sub.nix
              #   ./modules/deployment.nix
              #   ./modules/serviceForDeployment.nix
              #   # /home/adrian/code/rhinofi/kubenix-hall/docs/content/examples/namespaces/namespaced.nix
              # ];

              # submodules.specialArgs = {
              #   pkgs = self;
              #   parentConfig = config;
              # };

              # submodules.propagate.enable = false;

              # # kubernetes.resources.deployments.my-deploy = self.kubelib.resources.deployment {
              # #   name = "my-deploy";
              # #   image = "image";
              # # };
              # docker.images.hello.image = self.helloImage;
              # submodules.instances.my-deploy = {
              #   submodule = "deployment";
              #   args.image = self.helloImage;
              #   config.docker.registry.url = "eu.gcr.io/my-gcp-project";
              # };

              # submodules.instances.my-service = {
              #   submodule = "serviceForDeployment";
              #   args.port = 80;
              #   config._module.args.name = self.lib.mkForce "my-deploy";
              # };

              deployments.example.image = self.helloImage;
              # services.example = {};
              # deploymentsForProcesses.frontend = {};

              # submodules.instances.my-deploy-2 = {
              #   submodule = "deployment";
              # };
              # submodules.instances.simple = {
              #   submodule = "simple-sub";
              #   args.str = "1214";
              # };
              # submodules.instances.namespace-https = {
              #   submodule = "namespaced";
              #   args = {};
              # };
            })
            # (import /home/adrian/code/rhinofi/kubenix-hall/docs/content/examples/namespaces/module.nix)
            # ({ kubenix, config, ... }: {
            #   kubernetes.resources = self.kubelib.patches.exposeDeployment {
            #     name = "my-deploy";
            #   };
            # })
            {
              imports = [
                ./../services
                ./modules/processes-with-process-compose.nix
              ];
            }
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
