# Base Box
In order to create a new base box, three files are required:
- metadata.json: name the provider this box is for
- Vagrantfile: some basic settings
- disk.img: installed OS image

## Vagrantfile
The configurations here are used as defaults.
- config.vm.guest: set this to OpenBSD til detection is rock solid
- config.ssh.shell: set this to ksh to override bashism defaults in vagrant(?)

## disk.img
To create such an image, use the VMM base tools like this:
````
vmctl create disk.img -s 2G
doas vmctl start "myvm" -m 1G -L -i 1 -b /bsd.rd -d disk.img -c
````
Run through the installer add doas and HALT the machine
````
echo 'permit nopass keepenv root' > /mnt/etc/doas.conf
halt -p
````
Stop the vm on host
````
doas vmctl stop "myvm"
````

## Box bundling
It's a simple tar archive:
````
tar zcf myvm.box ./metadata.json ./Vagrantfile ./disk.img
````

## Adding the box
````
vagrant box add --provider=openbsd --name=myvm myvm.box
````
