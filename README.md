# Vagrant OpenBSD vmd(8) Provider

*NOTE* This is absolut alpha work-in-progress - DO NOT USE

This is a [Vagrant](http://www.vagrantup.com) 1.5+ plugin that adds an
[OpenBSD vmd(8)](https://man.openbsd.org/vmd) provider to Vagrant,
allowing Vagrant to control and provision machines on OpenBSD.

## Features

* Boot VM instances.
* SSH into the instances.
* Provision the instances with any built-in Vagrant provisioner.
* Setup of networking

## Installation

```
$ vagrant plugin install /path/to/vagrant-openbsd-provider.gem
$ doas pkg_add gtar-1.29
$ doas ln -s /usr/local/bin/tar /usr/local/bin/bsdtar
```
Yes. The OpenBSD tar is 'pax' and doesnt know all the
used options and I cannot make this call OS specific currently

## Usage

Once the plugin is installed, you use it with `vagrant up` by specifing
the `openbsd-provider` provider:
```
$ vagrant up --provider=openbsd-provider
```
