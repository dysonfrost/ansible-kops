# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|

  # Vagrant will choose the first provider that is usable.
  config.vm.provider "libvirt" do |_, override|
    # Set your vm IP address according to your preferred virtual priv subnet
    override.vm.network :private_network, type: "dhcp"
  end
  config.vm.provider "virtualbox" do |_, override|
    # Set your vm IP address according to your preferred virtual priv subnet
    override.vm.network :private_network, type: "dhcp"
  end


  # Ansible-Kops Dev
  config.vm.define "ansible-kops_dev" do |ubuntu|
    ubuntu.vm.hostname = "ansible-kops-dev"
    ubuntu.vm.box = "generic/ubuntu1604"
    ubuntu.vm.network :private_network, type: "dhcp"

    ubuntu.vm.provision "shell", inline: <<-EOC
      export DEBIAN_FRONTEND=noninteractive
      echo "Creating ssh keypair..."
      ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa -q -N ''
      echo "Installing prerequisites..."
      sudo apt-get update -qq && apt-get install -q -y \
      python \
      python-boto \
      python-boto3 \
      ca-certificates \
      jq \
      awscli > /dev/null
      sleep 2
      echo "Installing Ansible..."
      sudo apt-add-repository ppa:ansible/ansible -y
      sudo apt-get update -qq && apt-get install -q -y ansible > /dev/null
      echo "Installing Docker..."
      curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add - > /dev/null
      sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable"
      sudo apt-get update -qq && sudo apt-get install -q -y docker-ce > /dev/null
      sudo usermod -aG docker vagrant && sudo su - vagrant
      sudo systemctl enable docker
      echo "Installing Certbot..."
      sudo add-apt-repository ppa:certbot/certbot -y && sudo apt-get update -qq
      sudo apt-get install -q -y python3-certbot-dns-route53 > /dev/null
      echo "Cloning dysonfrost/ansible-kops repository..."
      git clone https://github.com/dysonfrost/ansible-kops.git
      cat <<-EOF

        ansible-kops is ready.
      
        use 'vagrant ssh' to connect to the virtual machine, cd to `ansible-kops` then setup the environment.

        - set an AWS IAM user using 'aws configure'
        - initiate a dns01 challenge using certbot-dns-route53 (optional if you've already done this before)
        - edit the group_vars directory
        - run ansible-playbook 'ansible-playbook deploy.yml'
        - to clean your AWS environment, run 'ansible-playbook cleanup.yml'
      
        use 'vagrant destroy -f" to delete the virtual machine

      EOF
      echo "ubuntu.vm.provision finished"
    EOC
  end
end
