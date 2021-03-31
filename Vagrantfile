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
    vb.cpus = 4
    vb.memory = 4096
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
    arkade install openfaas --basic-auth-password admin

    sudo chmod 606 /home/vagrant/kubeconfig
    sudo kubectl config set-context --current --namespace=openfaas
    sudo kubectl apply -f /vagrant/ingress-gateway.yml
    sudo kubectl delete service gateway-external
    sudo kubectl create deployment registry --image=registry:latest --namespace openfaas
    sudo kubectl expose deployment registry --namespace openfaas --type=LoadBalancer --port=5000 --target-port=5000

    curl -sSL https://cli.openfaas.com | sudo sh
    sudo apt-get install git -y
  SHELL

  config.vm.provision "docker"

  config.vm.provision "shell", path: "wait-for-it.sh"

  config.vm.provision "shell", inline: <<-SHELL
    faas login --password admin --gateway localhost:80
  SHELL
end

#faas login --password admin --gateway localhost:80
#faas build -f /vagrant/testinrust.yml
#docker push localhost:5000/testinrust
#faas deploy -f testinrust.yml
