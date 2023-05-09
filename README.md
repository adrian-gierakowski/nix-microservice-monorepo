# nix-microservice-monorepo

Things one could do:

1. run `frontend` service and all it's deps via [process-compose](https://github.com/F1bonacc1/process-compose)

```sh
nix run -f nix/pkgs.nix platform.prd.config.process-compose.frontend.runPackage
```

2. run just `frontend` process directly


```sh
nix run -f nix/pkgs.nix platform.prd.config.processes.frontend.runWithEnv
```

3. show k8s manifests for all services

```sh
cat $(nix-build nix/pkgs.nix -A platform.prd.config.kubernetes.resultYAML)
```

4. create are templated files

```sh
nix run -f nix/pkgs.nix platform.prd.config.files.create-all
```