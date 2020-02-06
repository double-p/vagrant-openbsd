# Development
For joint effort/contribution, these steps are necessary to create a workable (minimum) build environment

## Packages
as of 6.2-release
````
curl-7.55.1         get files from FTP, Gopher, HTTP or HTTPS servers
git-2.14.2          GIT - Tree History Storage Tool
ruby-2.3.5          object oriented script language with threads
ruby23-bundler-1.15.1 ruby application dependency manager
vmm-firmware-1.10.2p4 firmware binary images for vmm(4) driver
````

## Rubyenv
You might feel like rbenv or something, or just straight on:
````
 ln -sf /usr/local/bin/ruby23 /usr/local/bin/ruby
 ln -sf /usr/local/bin/erb23 /usr/local/bin/erb
 ln -sf /usr/local/bin/irb23 /usr/local/bin/irb
 ln -sf /usr/local/bin/rdoc23 /usr/local/bin/rdoc
 ln -sf /usr/local/bin/ri23 /usr/local/bin/ri
 ln -sf /usr/local/bin/rake23 /usr/local/bin/rake
 ln -sf /usr/local/bin/gem23 /usr/local/bin/gem
 ln -sf /usr/local/bin/bundler23 /usr/local/bin/bundler
 ln -sf /usr/local/bin/bundle23 /usr/local/bin/bundle
````

## Builds
````
git clone https://github.com/double-p/vagrant-openbsd.git
cd vagrant-openbsd
bundle install # install (many) GEM dependecies
rake build # build vagrant + plugin
bundle exec vagrant plugin install pkg/vagrant-openbsd-0.1.0.gem
bundle exec vagrant plugin list
bundle install --binstubs
````

