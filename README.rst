==============
 acme-wrapper
==============

A program wrapping acme-tiny to make administrating ssl certificates to
services on a host running debian reliable and automatic.

Specifically, the following functionality is implemented on top of
acme-tiny:

* **Automatically provide ssl private key file for each requested certificate.**

  As a convenience, acme-wrapper also handles the generation of ssl
  private key files. Currently a new private key is generated for each
  time a certificate is (re-)issued in order to automatically limit the
  impact a possible key-revealing ssl vulnerability has.

  As a disadvantage, this means that acme-wrapper will have access to
  all ssl private key files for all issued certificates. A future
  version of acme-wrapper might offer ways to limit this if some
  coordination with and support by the application (the application
  that will eventually use the issued ssl certificate) is implemented.
* **Automatically provide self-signed certificate if all else fails.**

  For example, apache2 does not start when a ssl certificate file is
  configured but the file does not exist. Therefore, by ensuring _some_
  ssl certificate file always exist, the service is just rendered
  insecure instead of denied; This is the preferred failure mode for
  virtually all public web pages without login-only area.
* **Automatically retrieve the full certificate chain up to the root**

  While let's encrypt and acme-tiny in their current forms do also
  provide the intermediate certificate together with the issued
  certificate, this was not the case previously and is also not
  guaranteed by the acme protocol standard (see RFC 8555). Acme-Wrapper
  was started when the intermediate certificate was not yet provided by
  acme-tiny.

  Acme-Wrapper will inspect the certificate handed over by acme-tiny,
  and retrieve any missing parts of the chain up to the root
  certificate, and all are made available to the application that uses
  the ssl certificate file.
* **Automatically re-request certificates**

  Acme-Wrapper uses cron to ensure that each requested certificate is
  renewed in time before it expires. While the documentation of
  acme-tiny already suggests to be automatically executed via cron each
  month, acme-wrapper tries to be more sophisticated about it.
  Currently, acme-wrapper checks for the need to re-request a
  soon-expiring certificate daily but only calls on acme-tiny if the
  need arises.

  Acme-Wrapper does not automatically reload or restart services.

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
