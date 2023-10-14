#!/usr/bin/python3
"""
Extracts the list of "Depends:" packages from the debian binary package.

- Assumes it is run during building a package, after
  debian/«package»/DEBIAN/control
  has been generated.
- If no binary package name was provided as argument, returns the
  merged dependency list of all binary packages.

The package list is written to STDOUT in a format suitable as arguments
to a `apt-get satisfy`. One output line translates to one argument.
However, empty output lines as well as output lines starting with '#'
must be ignored and not handed over to `apt-get satisfy`.

Arguments:
    $1 ... the base directory of the source files
    $2 ... optionally, the binary package (if not specified: all binary packages)
           TODO: not implemented at the moment.
"""

import logging
LOGFORMAT = '%(asctime)s - %(module)s:%(lineno)d %(levelname)s: %(message)s'
if "__main__" == __name__:
    logging.basicConfig(format=LOGFORMAT, level=logging.DEBUG)
logger = logging.getLogger(__name__)

import argparse
import pathlib
import subprocess


argparser = argparse.ArgumentParser()
argparser.add_argument("BASEDIR")
args = argparser.parse_args()


BASEDIR = pathlib.PosixPath(args.BASEDIR).resolve()


binary_packages = list()

deb_src_control_file = BASEDIR.joinpath("debian", "control")
with deb_src_control_file.open(mode="rt") as fp:
    # TODO: maybe there is some python3 module available to properly parse a deb-src-control file?
    for line in fp:
        if line.startswith("Package:"):
            package = line.partition(":")[2].strip()
            binary_packages.append(package)

depends_string = ""

# also using the deb-src-control file here, as debian/«package»/DEBIAN/control
# has not yet been generated (by dpkg-gencontrol) yet.
# i'm really not sure how to get the properly generated deb-control file
# at this point of the build process as for example the misc:Depends substvar
# is not determined yet (e.g. dh_installdebconf would come later and might
# set something)
for package in binary_packages:
    #deb_control_file = BASEDIR.joinpath("debian", package, "DEBIAN", "control")
    deb_control_file = BASEDIR.joinpath("debian", "control")
    with deb_control_file.open(mode="rt") as fp:
        # TODO: maybe there is some python3 module available to properly parse a deb-control file?
        in_depends = False
        for line in fp:
            if line.startswith("Depends:"):
                in_depends = True
                depends_string += line.partition(":")[2].lstrip()
            elif in_depends and line.startswith(" "):
                depends_string += line.lstrip()
            else:
                in_depends = False

depends_list = list()
for dep in depends_string.split(","):
    dep = dep.strip()
    if dep.startswith('$'):
        # skip items that are substvars
        continue
    if dep:
        depends_list.append(dep)

depends_list.sort()

print("# use `apt-get satisfy --no-install-recommends` to install the following dependencies:")
for dep in depends_list:
    print(dep)
