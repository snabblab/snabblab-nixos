{ writeScriptBin, utillinux }:

writeScriptBin "lock" ''
  #!/usr/bin/env bash

  if [ "$#" == 0 -o "$1" == "--help" -o "$1" == "-h" ]; then
    cat >&2 <<EOF
  Usage: $0 command...

  Run a command with the machine-wide Snabb Lab lock held.

  Holding this lock entitles the process to use resources such as PCI
  devices and CPU cores that are (informally) reserved for lab tests.

  (Please don't access those resources except when using this command to
  hold the lock. That could make your tests interfere with somebody
  else.)

  Note: This command sets the TMOUT environment variable so if you start
  an interactive shell such as bash then you will automatically have a
  one-hour idle timeout at the prompt.

  EOF
    exit 1
  fi

  lock=/var/lock/lab

  echo -n "locking $lock.. ">&2
  (${utillinux}/bin/flock --verbose 9 || exit 1
  # Set TMOUT variable in case the command is an interactive Unix shell.
  # This is a bit magical but hopefully okay for setting an idle timeout.
  TMOUT=$[60*60] "$@"
  ) 9>/var/lock/lab
''
