ENV['VAGRANT_DEFAULT_PROVIDER'] = 'libvirt'
IMAGEN = "generic/ubuntu2004"
HOSTNAME = "ping.cultura.lab"

#$script = <<-SCRIPT
#	sudo apt-get update
#	sudo apt-get install -y docker-compose
#SCRIPT

Vagrant.configure("2") do |config|
  config.ssh.insert_key = false
  config.vm.synced_folder ".", "/vagrant", type: "rsync", disabled: true

  config.vm.define :server do |s|
    s.vm.box = IMAGEN
    s.vm.hostname = HOSTNAME
    s.vm.box_check_update = false
#    s.vm.provision :docker
#    s.vm.provision "shell", inline: $script 

    s.vm.provider :libvirt do |v|
      v.memory = 2048
      v.cpus = 2
    end
  end
end
