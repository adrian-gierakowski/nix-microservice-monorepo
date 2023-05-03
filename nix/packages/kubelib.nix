{
  lib,
  kubenix,
  name ? null,
}:
lib.makeExtensible (self: {
  labels = {
    deploymentLabels = labels: {
      spec.template.metadata = { inherit labels; };
      spec.selector.matchLabels = labels;
    };
  };
  pathFromImage = image: "${image.imageName}:${image.imageTag}";
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
        labels = self.labels.deploymentLabels matchLabels;
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
        selector,
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
          inherit selector;
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
        containerPortEnvName ? "PORT",
        containerName ? "default",
        type ? "ClusterIP",
        selector ? { app = name; },
      }:
        {
          deployments.${name}.spec.template.spec.containers.${containerName} = {
            ports.${containerPortName} = {
              containerPort = containerPort;
              name = containerPortName;
            };
            env = if containerPortEnvName == null then {} else {
              "${containerPortEnvName}".value = toString containerPort;
            };
          };
          services.${name} = self.resources.service {
            inherit name type port;
            targetPort = containerPortName;
            inherit selector;
          };
        }
    ;
  };
  templates =  {
    deployments = ./../modules/templates/deployments.nix;
    services = ./../modules/templates/services.nix;
    deploymentsForProcesses = ./../modules/templates/deploymentsForProcesses.nix;
  };
})