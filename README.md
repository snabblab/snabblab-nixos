# snabblab-nixos

This repository contains the configuration for the [NixOS](http://nixos.org/nixos/support.html) based server(s) in the [Snabb Lab](http://snabbco.github.io/#snabblab).


# Making changes

All changes are done from `Eiger` server:

    $ ssh <yourusername>@eiger.snabb.co
    $ sudo su - deploy
    $ cd snabblab-nixos

## Deploying Eiger (supporting server)

    $ nixops deploy -d eiger


## Deploying the Lab

Change `machines/lab.nix` and deploy to a single machine:

    $ nixops deploy -d lab-production --include lugano-2

To deploy to all lab server change `modules/lab-configuration.nix` and:

    $ nixops deploy -d lab-production

# Setup (only for bootstrapping a new deployment)

[NixOps](https://nixos.org/nixops/manual/) is used for deployment and provisioning of the machines. It uses an sqlite database (`~/.nixops/deployments.nixops`) to store state about the provisioning. For example SSH keys, path to nix files, current partitions, etc.

To bootstrap a bare metal machine, it has to be running with a basic NixOS install. Then for the lab as an example do:

    $ nixops create -d lab-production ./machines/lab.nix ./machines/lab-production.nix

To bootstrap Hetzner machine we need partitions, IP, Hetzner Robot credentials as seen in:

    $ HETZNER_ROBOT_USER=<user> HETZNER_ROBOT_PASS=<pass> create -d eiger ./eiger.nix ./eiger-hetzner.nix

