# Flux

`https://v2-0.docs.fluxcd.io/flux/cheatsheets/bootstrap/`

`https://fluxcd.io/flux/installation/bootstrap/generic-git-server/`

```sh
mkdir -p clusters/my-cluster/flux-system
touch clusters/my-cluster/flux-system/gotk-components.yaml \
    clusters/my-cluster/flux-system/gotk-sync.yaml \
    clusters/my-cluster/flux-system/kustomization.yaml
```

Idea:

Flux bootstrap with git repo. But need to commit to repo for updates

setup git server and mount this repo into the git server 