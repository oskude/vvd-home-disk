# vvd-home-disk
**Vagrantfile for VirtualBox and Debian with home disk**

*vvd-home-disk* is a "simple" [Vagrantfile](https://docs.vagrantup.com/v2/vagrantfile/) that creates and/or uses an existing disk image (`vvd-home.vdi`) and mounts it as `/home` in the guest system.

Optionally *vvd-home-disk* loads `config.rb`, provisions with `provision-root.sh` and `provision-user.sh`.

Additionally *vvd-home-disk* detaches the home disk image during `vagrant destroy`, so it wont get automatically deleted.

## Usage

1. Get the [Vagrantfile](https://github.com/oskude/vvd-home-disk/blob/master/Vagrantfile)
1. Optionally, create [config.rb](https://github.com/oskude/vvd-home-disk/blob/master/config.rb)
1. Optionally, create [provision-root.sh](https://github.com/oskude/vvd-home-disk/blob/master/provision-root.sh)
1. Optionally, create [provision-user.sh](https://github.com/oskude/vvd-home-disk/blob/master/provision-user.sh)
1. Run `vagrant up`

## Todo

* make this a vagrant feature or plugin?

