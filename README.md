# K8s devcontainer

Work in progress...

Idea:

1) Setup k8s with fluxcd in devcontainers.
2) Use flux bootstrap to connect to local git server.
3) Figure out if this repo should add the local git server as an remote (support of push, and keep ssh key save)

## Prerequisites

1. Install Docker: [Docker Installation Guide](https://docs.docker.com/get-docker/)
2. Install Visual Studio Code: [VS Code Installation Guide](https://code.visualstudio.com/)
3. Install the Remote - Containers extension for VS Code: [Remote - Containers Extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers)

## Getting Started

1. Clone this repository:

   ```sh
   git clone git@github.com:tomsolem/k8s-dev.git
   cd k8s-dev
   ```

2. Open the repository in VS Code:

   ```sh
   code .
   ```

3. Open the repository in the dev container:

Press F1 and select Remote-Containers: Reopen in Container.

### Flux boostrap issues

for now it's not possible to bootstap flux with `git-server`. Need to solve this error:

```
clone failure: unable to clone 'ssh://git-server/srv/git/org/flux-gitops': ssh: handshake failed: ssh: unable to authenticate, attempted methods [none publickey], no supported methods remain
```
