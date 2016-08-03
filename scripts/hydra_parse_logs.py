#!/usr/bin/env nix-shell
#!nix-shell -i python -p pythonFull pythonPackages.requests pythonPackages.pyquery pythonPackages.click

# To use, just execute this script.

import re
import fnmatch

import click
import requests
from pyquery import PyQuery as pq


def globmatches(text, log):
    return fnmatch.fnmatch(log, text)


@click.command()
@click.option(
    '--url',
    prompt="Hydra evaluation URL",
    help='Hydra evaluation url, for example https://hydra.snabb.co/eval/2417?full=1 (lugano-medium)')
def cli(url):
    """Given a Hydra evaluation, parse logs of failed builds and print statistics"""

    all = 0
    mapping = 0
    timeout = 0
    terminated = 0
    overflow = 0
    no_tmux = 0
    net_device_assert = 0
    unknown = []

    print "Parsing logs of failed builds in {} to determine cause of failure:\n".format(url)

    resp = requests.get(url)  # I/O
    d = pq(resp.text)

    for a in d('img[alt="Failed with output"]').parents('tr').find('a[class="row-link"]'):
        build_link = a.get('href')
        print "Parsing log of {}".format(build_link)
        log = requests.get(build_link + "/log/raw").text  # I/O
        if "mapping to host address failed" in log:
            mapping += 1
        elif "Terminated" in log:
            terminated += 1
        elif "no server running on /tmp/tmux-0/" in log:
            no_tmux += 1
        elif "packet payload overflow" in log:
            overflow += 1
        elif "[TIMEOUT]" in log:
            timeout += 1
        elif globmatches("*lib/virtio/net_device.lua:*: assertion failed*", log):
            net_device_assert += 1
        else:
            unknown.append(build_link)
        all += 1
        # build_html = requests.get(build_link).text  # I/O

    print "Failed builds in total: {}".format(all)
    print "Failed builds due to 'mapping to host address failedcdata': {}".format(mapping)
    print "Failed builds due to being terminated after 2min: {}".format(terminated)
    print "Failed builds due to 'packet payload overflow': {}".format(overflow)
    print "Failed builds due to qemu telnet timeout: {}".format(timeout)
    print "Failed builds due to 'no server running on /tmp/tmux-0/default': {}".format(no_tmux)
    print "Failed builds due to 'lib/virtio/net_device.lua:254: assertion failed': {}".format(net_device_assert)
    print "Failed builds with unknown cause: {}: {}".format(len(unknown), unknown)


if __name__ == "__main__":
    cli()
