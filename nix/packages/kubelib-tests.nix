{
  lib,
  kubelib,
  name ? null,
}:
lib.extra.prependPrefixToAttrNames "test" {
  "resources.deployment: creates deployment with default name and labels" = {
    expr = kubelib.resources.deployment {
      name = "my-deploy";
      image = "image";
    };
    expected = {
      metadata = {
        name = {
          _type = "override";
          content = "my-deploy";
          priority = 1000;
        };
      };
      spec = {
        selector.matchLabels.app = "my-deploy";
        template = {
          metadata.labels.app = "my-deploy";
          spec.containers.default = {
            image = "image";
            name = {
              _type = "override";
              content = "my-deploy";
              priority = 1000;
            };
          };
        };
      };
    };
  };
  "resources.service: creates service" = {
    expr = kubelib.resources.deployment {
      name = "my-deploy";
      image = "image";
    };
    expected = {
      metadata = {
        name = {
          _type = "override";
          content = "my-deploy";
          priority = 1000;
        };
      };
      spec = {
        selector.matchLabels.app = "my-deploy";
        template = {
          metadata.labels.app = "my-deploy";
          spec.containers.default = {
            image = "image";
            name = {
              _type = "override";
              content = "my-deploy";
              priority = 1000;
            };
          };
        };
      };
    };
  };
}
