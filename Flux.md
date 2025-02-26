# Flux

`https://v2-0.docs.fluxcd.io/flux/cheatsheets/bootstrap/`

`https://fluxcd.io/flux/installation/bootstrap/generic-git-server/`

```sh
mkdir -p clusters/my-cluster/flux-system
touch clusters/my-cluster/flux-system/gotk-components.yaml \
    clusters/my-cluster/flux-system/gotk-sync.yaml \
    clusters/my-cluster/flux-system/kustomization.yaml
```

## setup

A git-server with a gitops repo.
Clone the repo to a /tmp/dev/ folder in dev container
copy content of this repo to /tmp/dev (or add a new remote).
Push changes and flux sync them into kubernetes.
