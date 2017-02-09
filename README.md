This documentation is aimed at **infrastructure developers**, for Snabb
**infrastructure usage** see the [Snabblab section in Snabb manual]
(http://snabbco.github.io/#snabblab).


# Overview of Snabblab CI infrastructure

Source code for managing infrastructure for [Snabb community]
(https://github.com/snabbco/snabb) providing tools to build, test and benchmark
Snabb software to developers.

Under the hood, [Nix](http://nixos.org/nix/) language is used.

Source code serves two purposes:

- [Hydra](https://nixos.org/hydra/) is a [CI]
  (https://en.wikipedia.org/wiki/Continuous_integration) used by Snabb
  developers to test and benchmark different kinds of applications in Snabb.
  Relevant folders are `jobsets` and `lib`.

- Server deployments using [NixOps](http://nixos.org/nixops/) and Hydra.
  Relevant folders are `machines`, `pkgs` and NixOS `modules`.


# Motivations for Snabblab infrastructure

Following separate topics are all covered in this repository.


## Snabb development

Snabblab is a group of servers with attached Networking cards on
which Snabb can be developed and used. The cluster needs to be managed
and deployed without too much hustle.


## Testing Snabb

Snabb has unit and functional tests that require specific setup and environment
to run successfully.


## Benchmarking Snabb

It's critical that Snabb doesn't regress in performance throughout development.

Different Snabb applications integrate into other software, requiring
interesting set of software combinations to be benchmarked with.

For example:

- 10 different test cases.
- 5 versions of QEMU.
- 10 different guest VMs (Linux and DPDK).
- 16 combinations of Virtio-net options.
- 2 NUMA setups ("good" and "bad")
- 2 polling modes (engine "busy loop" and sleep/backoff)
- 2 error recovery modes (engine supervising apps vs process restart)
- 2 C libraries (glibc and musl)
- 3 CPUs (Sandy Bridge, Haswell, Skylake)


## Prerequesites 

Be familiar with:

- Nix language using [a tutorial]
  (https://medium.com/@MrJamesFisher/nix-by-example-a0063a1a4c55#.oqowlpqf2)
  and [the official reference sheet]
  (http://nixos.org/nix/manual/#chap-writing-nix-expressions)

- existence of [basic Nix datatype manipulation functions]
  (https://github.com/NixOS/nixpkgs/tree/master/lib)

- [NixOS modules semantics]
  (http://nixos.org/nixos/manual/index.html#sec-writing-modules)


## Hydra

The very core of Hydra are **jobsets**. They define configuration
**how and when** a specific Nix expression is executed.

Jobsets are grouped into projects for easier separation of concerns.

For example, [snabb/master]
(https://hydra.snabb.co/jobset/snabb/master#tabs-configuration) means
**master** jobset for **snabb** project.

[jobsets/snabb.nix]
(https://github.com/snabblab/snabblab-nixos/blob/master/jobsets/snabb.nix#L1-L8)
expressions is evaluated using the highlighted function inputs that jobset
configures.

 The jobset configuration page defines:

- evaluate `jobsets/snabb.nix` in input named `snabblab` (which fetches
  https://github.com/snabblab/snabblab-nixos.git into Nix store).
- pass `snabbSrc` function input as https://github.com/snabbco/snabb.git
  imported into Nix store
- pass `nixpkgs` available in [Nix search path]
  (http://lethalman.blogspot.si/2014/09/nix-pill-15-nix-search-paths.html)
  to be imported anywhere in the expression

Once evaluation is triggered (every 300 seconds in this case), inputs are
fetched and the whole Nix expression is evaluated. For each Nix [derivation]
(http://nixos.org/nix/manual/#ssec-derivation) the hash is calculated and if it
changes, the derivation is rebuilt.

[An example evaluation](https://hydra.snabb.co/eval/2774) shows that all jobs
still succeed. Under the "Inputs" tab one can observe what inputs were used in
this specific evaluation and due to Nix design and property of [referential
transparency](https://en.wikipedia.org/wiki/Referential_transparency), one
should always get the same derivations for those inputs.

Each job can also provide "build products" which define what files are inside
the resulting derivations and ready for download. Clicking on the [manual
job](https://hydra.snabb.co/build/173605) it lists different files representing
manual formats contained inside the Nix store path.


### Testing

[jobsets/snabb.nix]
(https://github.com/snabblab/snabblab-nixos/blob/master/jobsets/snabb.nix) is
built using the following [Hydra jobset](https://hydra.snabb.co/project/snabb)
given Snabb tarball which is fetch from Github (at given release):

- Snabb binary
- Snabb manual
- Snabb tests (make test)
- Snabb, not using Nix expression but rather packages on specific distribution
  (CentOS, OpenSUSE, Debian, Ubuntu, Fedora)

Note: clicking on specific jobset, on "Configuration" tab one can see what
inputs are used for the Nix expression: here is an [example]
(https://hydra.snabb.co/jobset/snabb/master#tabs-configuration).


### Benchmarking

[jobsets/snabb-matrix.nix]
(https://github.com/snabblab/snabblab-nixos/blob/master/jobsets/snabb-matrix.nix)
is built using [Hydra jobset]
(https://hydra.snabb.co/project/snabb-new-tests) given multiple Snabb inputs.

The jobset will build all specified Snabb branches (`snabbXsrc`/`snabbXname`
pairs). Additionally, you specify which `qemuVersions`, `dpdkVersions`,
`kernelVersions` will be used. Using all these software versions, a big matrix
of combinations of inputs is computed and used to execute selected benchmarks.

`benchmarkNames` is a list of [benchmark names]
(https://github.com/snabblab /snabblab-nixos/blob/master/lib/benchmarks.nix#L279-L299)
being executed on the matrix.

`numTimesRunBenchmark` input specifies how many times each benchmarks is
executed.

`nixpkgs` points to a specific commit, pinning all software used.

Once all benchmarks are executed, a big CSV file is generated based on results.

Last but not least, `reports` is a list of [reports names]
(https://github.com/snabblab/snabblab-nixos/tree/master/lib/reports)
that consumes the CSV and produces a nice report using R and markdown.

 
#### Under the hood of a specific benchmark (outputs)

Infrastructure behind a call to execute a benchmark consists of jobset function
outputs, spans over 700 lines in `jobsets/snabb-matrix.nix` file and supporting
`lib/` folder and begins at [building all software used in the matrix]
(https://github.com/snabblab/snabblab-nixos/blob/master/jobsets/snabb-matrix.nix#L52-L65).

Snabb, Qemu, DPDK and Kernel packages are first [filtered based on versions
specified]
(https://github.com/snabblab/snabblab-nixos/blob/master/jobsets/snabb-matrix.nix#L52-L66)
in the matrix and then [built using overriden upstream expressions]
(https://github.com/snabblab/snabblab-nixos/blob/master/lib/software.nix#L7-L82).

All [matrix software used]
(https://github.com/snabblab/snabblab-nixos/blob/master/jobsets/snabb-matrix.nix#L89)
is [built as part of the jobset]
(https://hydra.snabb.co/eval/3177?filter=software&compare=3083&full=).

Using sets of different (Snabb/Qemu/Dpdk/kernel) versions and names of benchmarks,
[a huge list of benchmark derivations is generated]
(https://github.com/snabblab/snabblab-nixos/blob/master/jobsets/snabb-matrix.nix#L69-L85). 

Once [selectBenchmarks]
(https://github.com/snabblab/snabblab-nixos/blob/master/lib/benchmarks.nix#L275-276)
is called with names of benchmarks, number of times to be executed and one set
of software [it selects benchmark by name]
(https://github.com/snabblab/snabblab-nixos/blob/master/lib/benchmarks.nix#L279-299).

Specific benchmark such as [mkMatrixBenchPacketblaster]
(https://github.com/snabblab/snabblab-nixos/blob/master/lib/benchmarks.nix#80-94)
calls [mkSnabbBenchTest]
(https://github.com/snabblab/snabblab-nixos/blob/master/lib/benchmarks.nix#L24-55)
with a few important inputs:

- `name` just being the identifier of the benchmark
- `checkPhase` in bash executing the benchmark itself and writing output to
  stdout and a log file
- `toCSV` taking derivation result as input and extracting benchmarking value
  out of it

[mkSnabbBenchTest]
(https://github.com/snabblab/snabblab-nixos/blob/master/lib/benchmarks.nix#L24-55)
calls [mkSnabbTest]
(https://github.com/snabblab/snabblab-nixos/blob/master/lib/testing.nix#L27-L92)
as many `times` as we specified and returns that many benchmarks/derivations as
a set.

[mkSnabbTest]
(https://github.com/snabblab/snabblab-nixos/blob/master/lib/testing.nix#L27-L92)

provides an environment in which all Snabb tests/benchmark are executed. All
software and environment settings are configured for `checkPhase` to execute
correctly. For some benchmarks/tests `~/.test_env` inside the chrooted
environment is populated using [mkTestNixEnv]
(https://github.com/snabblab/snabblab-nixos/blob/master/lib/test_env.nix)
function that builds two qemu images (one plain NixOS and one with dpdk l2fwd
running) and corresponding `bzImage` and `initrd` kernel fixtures.

Using all executed benchmarks, [mkBenchmarkCSV] generates
(https://github.com/snabblab/snabblab-nixos/blob/master/lib/benchmarks.nix#L200-217)
[one big CSV]
(https://github.com/snabblab/snabblab-nixos/blob/master/jobsets/snabb-matrix.nix#L91)
consisting of inputs specification and measures benchmarking values.

At the end, [reports are generated]
(https://github.com/snabblab/snabblab-nixos/blob/master/jobsets/snabb-matrix.nix#L92-L98)
using benchmark list and corresponding CSV files. [mkBenchmarkReport]
(https://github.com/snabblab/snabblab-nixos/blob/master/lib/benchmarks.nix#L222-L249)
uses R to generate HTML report.


## Snabblab deployments

Note: this is [very WIP](https://github.com/snabblab/snabblab-nixos/pull/39)
and not all servers are deployed using this workflow yet.


### Initial deploy

[NixOps](https://nixos.org/nixops/manual/) is used for provisioning the
machines.

   $ ssh user@eiger.snabb.co
   $ cd snabblab-nixos

It uses an sqlite database (`~/.nixops/deployments.nixops`) to store state
about the provisioning. For example SSH keys, path to nix files, current
partitions, etc.

First, create a nixops deployment:

    $ nixops create -d lab-production ./machines/lab.nix ./machines/lab-production.nix


#### Bare metal

1. The server needs a basic NixOS install running SSH with your public key
   configured.

2. Edit `machines/lab.nix` and `machines/lab-production.nix` and add a new machine.

3. Bootstrap:

    $ nixops deploy -d lab-production --include mymachine


#### Hetzner

1. Edit `machines/lab.nix` and `machines/lab-production.nix` and add a new
   machine.

2. To bootstrap Hetzner machine we need to use https://robot.your-server.de/
   account:

    $ HETZNER_ROBOT_USER=<user> HETZNER_ROBOT_PASS=<pass> deploy -d lab-production --include mymachine

3. Copy generated Nix configuration into separate file:

    $ nixops export -d lab-production | ./convert_export.py > ./machines/lab-export.nix 


### Automatic deployments

A developer pushes a configuration change into Git, Hydra builds and tests it,
servers are setup to automatically update themselves from Hydra. For each
machine there is a [separate channel]
(https://hydra.snabb.co/jobset/domenkozar-sandbox/snabblab#tabs-channels)
that serves up that machine's software and configuration.

This is WIP and only build- machines are automatically deployed.


### Testing Snabblab changes manually

TODO


## Snabblab development

Some changes in the repository may trigger massive rebuilds, for example
some benchmarks can take more than a day to execute.

For this reason, such changes should go to the `next` branch.
