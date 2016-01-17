# see https://github.com/oskude/vvd-home-disk for more info
# version 0.1.0
$vvd_home_size    = 1000
$vvd_home_file    = "vvd-home.vdi"
$vvd_home_id_file = ".vvd-home.id"
$vvd_config_file  = "config.rb"
$vvd_root_provision_file = "provision-root.sh"
$vvd_user_provision_file = "provision-user.sh"

if File.exists?($vvd_config_file)
	load $vvd_config_file
else
	Vagrant.configure(2) do |config|
		config.vm.box = "debian/jessie64"
	end
end

VVD_FILE_ROOT  = File.dirname(File.expand_path(__FILE__))
$VVD_DISK_ID   = File.join(VVD_FILE_ROOT, $vvd_home_id_file)
$VVD_DISK_FILE = File.join(VVD_FILE_ROOT, $vvd_home_file)
$VVD_DISK_SIZE = $vvd_home_size.to_s

PROVISION_DISK = <<-_____
	disk=/dev/disk/by-id/$(<#{$vvd_home_id_file})
	apt-get install -y gdisk rsync
	apt-get clean
	if [[ ! -e ${disk}-part1 ]]; then
		### Partition, format and copy new home disk
		sgdisk -n 0:0:0 -t 0:8300 $disk
		sleep 1 # TODO: how to make sure partition is done?
		mkfs.ext4 ${disk}-part1
		mount ${disk}-part1 /mnt
		rsync -ax /home/ /mnt/
		umount /mnt		
	fi
	if ! findmnt /home; then
		### Mount and update existing home disk
		echo "${disk}-part1 /home ext4 defaults 0 0" >> /etc/fstab
		mount ${disk}-part1 /mnt
		rsync -ax /home/vagrant/.ssh/authorized_keys /mnt/vagrant/.ssh/
		rsync -ax /home/vagrant/.vbox_version /mnt/vagrant/
		umount /mnt
		mount /home
	fi
_____

Vagrant.configure(2) do |config|
	!File.exist?($VVD_DISK_ID) ? File.open($VVD_DISK_ID, "w") {} : nil
	config.vm.provision "file",  source: $VVD_DISK_ID, destination: $vvd_home_id_file
	config.vm.provision "shell", inline: PROVISION_DISK
	if File.exist?($vvd_root_provision_file)
		config.vm.provision "shell", inline: File.read($vvd_root_provision_file)
	end
	if File.exist?($vvd_user_provision_file)
		config.vm.provision "shell", inline: File.read($vvd_user_provision_file), privileged: false
	end
end

class VagrantPlugins::ProviderVirtualBox::Action::SetName
	alias_method :original_call, :call
	def call(env)
		ui = env[:ui]
		driver = env[:machine].provider.driver
		uuid = driver.instance_eval { @uuid }
		vm_info = driver.execute("showvminfo", uuid, "--machinereadable")
		controller_name = vm_info[/storagecontrollername\d="(.*SATA.+)"/,1]
		if !File.exist?($VVD_DISK_FILE)
			ui.info "Creating home disk '#{$VVD_DISK_FILE}'..."
			driver.execute(
				"createmedium", "disk",
				"--filename", $VVD_DISK_FILE,
				"--format", "VDI",
				"--size", $VVD_DISK_SIZE
			)
		end
		if controller_name.to_s.empty?
			controller_name = "SATA Whatever"
			ui.info "Creating storage controller '#{controller_name}'..."
			driver.execute(
				"storagectl", uuid,
				"--name", "#{controller_name}",
				"--add", "sata",
				"--controller", "IntelAhci",
				"--portcount", "1",
				"--hostiocache", "off"
			)
		end
		ui.info "Attaching '#{$VVD_DISK_FILE}' to '#{controller_name}'..."
		driver.execute(
			"storageattach", uuid,
			"--storagectl", "#{controller_name}",
			"--port", "1",
			"--type", "hdd",
			"--medium", $VVD_DISK_FILE
		)
		work_disk_info = driver.execute("showmediuminfo", $VVD_DISK_FILE)
		work_disk_uuid = work_disk_info.match(/^UUID\:\s*([a-z0-9\-]+)/).captures[0]
		uuid_blocks = work_disk_uuid.split("-")
		disk_by_id = "ata-VBOX_HARDDISK_VB"
		disk_by_id += uuid_blocks[0] + "-"
		disk_by_id += uuid_blocks[-1][10..11]
		disk_by_id += uuid_blocks[-1][8..9]
		disk_by_id += uuid_blocks[-1][6..7]
		disk_by_id += uuid_blocks[-1][4..5]
		File.open($VVD_DISK_ID, "w") {|f| f.write(disk_by_id) }
		original_call(env)
	end
end

class VagrantPlugins::ProviderVirtualBox::Action::Destroy
	alias_method :original_call, :call
	def call(env)
		ui = env[:ui]
		driver = env[:machine].provider.driver
		uuid = driver.instance_eval { @uuid }
		vm_info = driver.execute("showvminfo", uuid, "--machinereadable")
		workdisk_filename = $VVD_DISK_FILE.split('/')[-1]
		controller_string = vm_info[/^"([^"]+)".*#{workdisk_filename}"$/,1]
		if !controller_string.to_s.empty?
			controller_name = controller_string[/(.+)-\d-\d$/,1]
			controller_port = controller_string[/(\d)-\d$/,1]
			ui.info "Detaching '#{$VVD_DISK_FILE}' from '#{controller_name}'..."
			driver.execute(
				"storageattach", uuid,
				"--storagectl", "#{controller_name}",
				"--port", "#{controller_port}",
				"--medium", "none"
			)
		end
		original_call(env)
	end
end

