acme-wrapper
============

A program wrapping acme-tiny to make administrating ssl certificates to debian servers reliable and automatically.

see http://qyanu.net/software/acme-wrapper

The package includes and re-distributes a copy of the software ``acme-tiny``.

see ``https://github.com/diafygi/acme-tiny``

Tested with and designed for debian 8 "jessie". Contributions to expand compatibility to other OS are welcome.


Installation
------------

This package is designed to be a FHS 3.0 compliant "Add-on application software package" named ``acme-wrapper``.

To install, using the included ``Makefile`` is recommended.

.. code:: bash
    make
    make install
    make install-crontab


Authors
-------

acme-wrapper was written by Max-Julian Pogner <max-julian@qyanu.net>

acme-tiny.py was written by Daniel Roesler <diafygi@gmail.com>
