Vagrant.configure("2") do |config|
  config.vm.define "master" do |master|
    master.vm.synced_folder "./source", "/home/vagrant/source"
    master.vm.box = "centos6.5"
    master.vm.network "private_network", ip: "192.168.20.100"
    master.vm.provision "shell", inline: "echo 'aaa' > /tmp/aaa"
    master.vm.provision "shell", path: "./source/provisionMaster.sh"
  end

  config.vm.define "slave1" do |slave1|
    slave1.vm.synced_folder "./source", "/home/vagrant/source"
    slave1.vm.box = "centos6.5"
    slave1.vm.network "private_network", ip: "192.168.20.101"
    slave1.vm.provision "shell", path: "./source/provisionSlave1.sh"
  end

  config.vm.provider :virtualbox do |vb|
    vb.customize ["modifyvm", :id, "--memory", "512"]
    vb.customize ["modifyvm", :id, "--cpus", "1"]
  end
end
