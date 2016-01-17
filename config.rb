$vvd_home_size = 4000

Vagrant.configure(2) do |config|
	config.vm.box = "debian/jessie64"
	config.vm.hostname = "hello.world"
	config.vm.network "private_network", ip: "10.20.30.40"
	config.vm.synced_folder '.', '/vagrant', disabled: true
end

