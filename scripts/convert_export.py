#!/usr/bin/env nix-shell
#!nix-shell -i python -p nixops

"""
Usage:

  $ nixops export -d eiger | ./convert_export.py > eiger-production.nix

"""

import json

from nixops.nix_expr import py2nix, nix2py


with open('eiger.export') as f:
    with open('eiger-production.nix', 'w') as out:
        deployments = json.load(f)
        out.write("{")
        # uses slightly modified logic of nixops/backends/hetzner.py:560
        for deployment in deployments.values():
            print "{"
            for machine, config in deployment['resources'].items():
                pyconfig = {
                    'config': dict(
                         eval(config['hetzner.networkInfo']).items() + {
                         ('users', 'extraUsers', 'root', 'openssh',
                         'authorizedKeys', 'keys'): [config['hetzner.sshPublicKey']]
                    }.items()),
                    'imports': [nix2py(config['hetzner.fsInfo']), nix2py(config['hetzner.hardwareInfo'])],
                }
                print "{0} = {1};".format(machine, py2nix(pyconfig))
            print "}"
