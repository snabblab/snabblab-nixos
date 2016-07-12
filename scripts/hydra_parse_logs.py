#!/usr/bin/env nix-shell
#!nix-shell -i 'python hydra_parse_logs.py' -p pythonFull pythonPackages.requests pythonPackages.pyquery

# To use, just execute this script.

import requests
from pyquery import PyQuery as pq


# benchmarks-lugano-medium
HYDRA_EVAL = "https://hydra.snabb.co/eval/2417?full=1"
# benchmarks-murren-large
#HYDRA_EVAL = "https://hydra.snabb.co/eval/2380?full=1"
print "Parsing logs of failed builds in {} to determine cause of failure:\n".format(HYDRA_EVAL)

all = 0
mapping = 0
timeout = 0
terminated = 0
overflow = 0
no_tmux = 0


# parse evaluation page and get HTML
resp = requests.get(HYDRA_EVAL)
d = pq(resp.text)

for a in d('img[alt="Failed with output"]').parents('tr').find('a[class="row-link"]'):
    build_link = a.get('href')
    print "Parsing log of {}".format(build_link)
    log = requests.get(build_link + "/log/raw").text
    if "mapping to host address failed" in log:
        mapping += 1
    elif "Terminated" in log:
        no_tmux += 1
    elif "no server running on /tmp/tmux-0/" in log:
        terminated += 1
    elif "packet payload overflow" in log:
        overflow += 1
    elif "[TIMEOUT]" in log:
        timeout += 1
    else:
        import pdb;pdb.set_trace()
        print log
    all += 1
    build_html = requests.get(build_link).text

print "Failed builds in total: {}".format(all)
print "Failed builds due to 'mapping to host address failedcdata': {}".format(mapping)
print "Failed builds due to being terminated after 2min: {}".format(terminated)
print "Failed builds due to 'packet payload overflow': {}".format(overflow)
print "Failed builds due to qemu telnet timeout: {}".format(timeout)
print "Failed builds due to 'no server running on /tmp/tmux-0/default': {}".format(no_tmux)
