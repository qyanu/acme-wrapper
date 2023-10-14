#!/usr/bin/python3
"""
Extracts the list of "Build-Depends:" packages from the debian source package.

The package list is written to STDOUT in a format suitable as arguments
to a `apt-get satisfy`. One output line translates to one argument.
However, empty output lines as well as output lines starting with '#'
must be ignored and not handed over to `apt-get satisfy`.

Arguments:
    $1 ... the base directory of the source files
"""

import logging
LOGFORMAT = '%(asctime)s - %(module)s:%(lineno)d %(levelname)s: %(message)s'
if "__main__" == __name__:
    logging.basicConfig(format=LOGFORMAT, level=logging.DEBUG)
logger = logging.getLogger(__name__)

import argparse
import pathlib


argparser = argparse.ArgumentParser()
argparser.add_argument("BASEDIR")
args = argparser.parse_args()


BASEDIR = pathlib.PosixPath(args.BASEDIR).resolve()

build_depends_string = ""

deb_src_control_file = BASEDIR.joinpath("debian", "control")
with deb_src_control_file.open(mode="rt") as fp:
    # TODO: maybe there is some python3 module available to properly parse a deb-control file?
    in_depends = False
    for line in fp:
        if line.startswith("Build-Depends:"):
            in_depends = True
            build_depends_string += line.partition(":")[2].lstrip()
        elif in_depends and line.startswith(" "):
            build_depends_string += line.lstrip()
        else:
            in_depends = False

build_depends_list = list()
for dep in build_depends_string.split(","):
    dep = dep.strip()
    if dep:
        build_depends_list.append(dep)

build_depends_list.sort()

print("# use `apt-get satisfy --no-install-recommends` to install the following dependencies:")
for dep in build_depends_list:
    print(dep)
