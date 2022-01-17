# Testing releases using snabblab-nixos in 2022

These are different times today. Many years have passed,
and hydra.snabb.co and the Murren servers’
operation have been discontinued.

However, we can still use snabblab-nixos
to run the benchmark matrix of olden times,
and generate reports.

We need to checkout this branch on snabblab-nixos,
on a server that suits our purposes.
The trusty Lugano’s are still alive!

I have updated modules/sudo-in-builds.nix,
which you need to copy to /etc/nixos/,
and import into configuration.nix.
The module has been observed to work at least
on Nixos 19.09.1247.851d5bdfb04 (Loris).

We also need the system to advertise features:
"lugano" and "murren".
To mimick the build servers of the past.

And do not forget to set nix.maxJobs = 1,
as we do not have a locking mechanism.


```
  imports =
    [
      # ...
      ./sudo-in-builds.nix
    ];
  nix.systemFeatures = [ "local" "lugano" "murren" "kvm" "nixos-test" "benchmark" ];
  nix.maxJobs = 1;
```

After a `nixos-rebuild switch`
you should be able to run a campaign
for example like so

```
#!/usr/bin/env bash

numTimesRunBenchmark=20

repositoryA=snabbco/snabb
branchA=master
nameA=master

repositoryB=snabbco/snabb
branchB=max-next
nameB=max-next

# reports: basic, report-by-snabb, report-full-matrix, vita

nix-build \
    --arg numTimesRunBenchmark "${numTimesRunBenchmark}" \
    --argstr snabbAname "${nameA}" \
    --arg snabbAsrc "builtins.fetchTarball https://github.com/${repositoryA}/tarball/${branchA}" \
    --argstr snabbBname "${nameB}" \
    --arg snabbBsrc "builtins.fetchTarball https://github.com/${repositoryB}/tarball/${branchB}" \
    --arg reports '["report-by-snabb"]' \
    --arg benchmarkNames '[ "basic" "iperf-base" "iperf-filter" "iperf-ipsec" "iperf-l2tpv3" "packetblaster" "packetblaster-synth" "dpdk-soft-base-256" "dpdk-soft-nomrg-256" "dpdk-soft-noind-256" ]' \
    --arg qemuVersions '["2.6.2"]' \
    --arg dpdkVersions '["16.11"]' \
    --show-trace \
    -A benchmark-csv \
    -A benchmark-reports \
    jobsets/snabb-matrix.nix
```