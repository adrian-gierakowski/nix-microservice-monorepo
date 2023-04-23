{
  lib,
  kubenix,
  name ? null,
}:
lib.makeExtensible (self: {
  labels = {
    selectorMatch = labels: {
      spec.template.metadata = { inherit labels; };
      spec.selector.matchLabels = labels;
    };
  };
  resources = {
    deployment = {
      name,
      # either image or docker is required
      # TODO: add assert with the above message message
      image ? docker.images.${name}.path,
      docker ? null,
      matchLabels ? { app = name; }
    }:
      let
        labels = self.labels.selectorMatch matchLabels;
        deploy = {
          metadata = { inherit name; };
          spec = {
            template.spec = {
              containers.default = {
                inherit
                  name
                  image
                ;
              };
            };
          };
        };
      in
        lib.recursiveUpdate
          deploy
          labels
    ;
    service =
      {
        name,
        port ? 80,
        protocol ? "TCP",
        targetPort ? "default",
        type ? "ClusterIP",
      }:
      {
        metadata = { inherit name; };
        spec = {
          ports.default = {
            inherit
              port
              protocol
              targetPort
            ;
            name = "default";
          };
          type = lib.mkDefault type;
        };
      }
    ;
  };
  patches = {
    exposeDeployment =
      {
        name,
        port ? 80,
        containerPort ? 8080,
        containerPortName ? "default",
        containerName ? "default",
        serviceType ? "ClusterIP",
      }:
        {
          deployments.${name}.spec.template.spec.containers.${containerName}.ports.${containerPortName} = {
            containerPort = containerPort;
            name = containerPortName;
          };
          services.${name} = self.resources.service {
            inherit name;
            type = serviceType;
            targetPort = containerPortName;
          };
        }
    ;
  };
})