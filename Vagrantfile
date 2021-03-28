# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "debian/buster64"

  config.vm.network "forwarded_port", guest: 80, host: 80

  config.vm.network "private_network", ip: "192.168.10.50"
  config.vm.synced_folder "./files", "/vagrant"

  if Vagrant.has_plugin?("vagrant-vbguest")
    config.vbguest.auto_update = false
  end

  config.vm.provider "virtualbox" do |vb|
    vb.cpus = 2
    vb.memory = 2048
  end

  config.vm.provision "shell", inline: <<-SHELL
    echo fs.inotify.max_queued_events = 16384 >> /etc/sysctl.conf
    echo fs.inotify.max_user_instances = 128 >> /etc/sysctl.conf
    echo fs.inotify.max_user_watches = 16384 >> /etc/sysctl.conf
    sudo sysctl -p

    curl -sLS https://get.k3sup.dev | sh
    sudo install k3sup /usr/local/bin/
  
    export K3S_KUBECONFIG_MODE="644"
    k3sup install --local

    export KUBECONFIG=/home/vagrant/kubeconfig
    sudo chown vagrant:vagrant /home/vagrant/kubeconfig
    sudo chmod 600 /home/vagrant/kubeconfig
    sudo kubectl config set-context default

    curl -SLsf https://dl.get-arkade.dev/ | sudo sh
    arkade install openfaas --set basic_auth=false

    sudo chmod 606 /home/vagrant/kubeconfig
    sudo kubectl config set-context --current --namespace=openfaas
    sudo kubectl apply -f /vagrant/ingress-gateway.yml
    sudo kubectl delete service gateway-external
  SHELL
end
