==============
 acme-wrapper
==============

A program wrapping acme-tiny to make administrating ssl certificates to
debian servers reliable and automatic.

See `<https://github.com/diafygi/acme-tiny>`_ for the wrapped software.

The homepage for this project is `<https://qyanu.net/software/acme-wrapper>`_ .

Tested with and designed for debian 12 "bookworm". Contributions to
expand compatibility to other OS are welcome.


Installation
------------

#. Install the debian package ``acme-wrapper``.
#. Configure your webserver to serve the files from
   ``/var/lib/acme-wrapper/www/`` under url(s)
   ``http://«domain»/.well-known/acme-challenge/`` of **all**
   domains listed in the to-be issued certificates.

   Example configuration files for some webservers are provided under
   ``/usr/share/doc/acme-wrapper/example/``.
#. Edit ``/etc/acme-wrapper/domains.list`` and list your desired
   certificates.
#. Initiate automatic certificate issuance, for example using crontab.

   ::

    cp /usr/share/doc/acme-wrapper/example/crontab \
       /etc/cron.d/acme-wrapper


Building
--------

This package is intended to be a well-behaving debian package named
``acme-wrapper``, albeit not part of the official distribution.

To build the package, the following command is recommended:

.. code:: bash

    debuild


Docker-based tests have been started to be created, they can be run as
part of the deb package building process.


Authors
-------

acme-wrapper was written by Max-Julian Pogner <max-julian@pogner.at>,
with debian packaging started by Christian M. Amsüss <chrysn@fsfe.org>.

acme-tiny.py was written by Daniel Roesler <diafygi@gmail.com>.
