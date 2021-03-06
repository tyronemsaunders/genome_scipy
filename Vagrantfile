# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
  # install cookbooks into 'chef-repo/cookbooks/ directory on host machine before provisioning
  config.trigger.before :up do
    run "berks vendor './chef-repo/cookbooks' --delete --berksfile ./Berksfile"
  end
  
  config.trigger.after :destroy do
    run "rm -rf './chef-repo/cookbooks'"
  end
  
  # organization name for the Chef Server
  orgname = "ORGNAME"
  
  # Chef Environment
  chef_environment = "development"

  ####################################
  ############# Box Setup ############
  ####################################

  # Every Vagrant development environment requires a box. You can search for
  # boxes at https://atlas.hashicorp.com/search.

  # Official Ubuntu 16.04 LTS (Xenial Xerus) Daily Build is broken (https://bugs.launchpad.net/cloud-images/+bug/1569237)
  config.vm.box = "bento/ubuntu-16.04"

  ####################################
  ########### Chef Version ###########
  ####################################

  # vagrant-omnibus is a  Vagrant plugin that ensures the desired version
  # of Chef is installed via the platform-specific Omnibus packages.
  # Install vagrant-omnibus using the command...
  # $ vagrant plugin install vagrant-omnibus

  config.omnibus.chef_version = "12.19.33" #:latest

  ####################################
  ######### Hosts Management #########
  ####################################

  # vagrant-hostmanager is a plugin that manages the hosts file
  # on guest machines (and optionally the host).
  # install vagrant-hostmanager using the command...
  # $ vagrant plugin install vagrant-hostmanager

  # enable the vagrant-hostmanager plugin
  config.hostmanager.enabled = true
  # update the host machine's etc/hosts file
  config.hostmanager.manage_host = true
  # enable the use of the private network IP address when set to true
  config.hostmanager.ignore_private_ip = false
  # boxes that are up or have a private ip configured will be added to the hosts file
  config.hostmanager.include_offline = true

  ####################################
  ############ Berkshelf #############
  ####################################

  # Vagrant Berkshelf is a Vagrant plugin that adds Berkshelf
  # integration to the Chef provisioners.
  # install vagrant-berkshelf using the command...
  # $ vagrant plugin install vagrant-berkshelf
  
  # path to the Berksfile to use
  config.berkshelf.berksfile_path = "./Berksfile"
  # enable berkshelf
  config.berkshelf.enabled = false

  ####################################
  #### Node/Server Configuration #####
  ####################################

  root_dir = File.dirname(File.expand_path(__FILE__))

  # node/server description files have been written in JSON format
  # Create an array of directory streams for node files.  Node files are in root_dir/chef-repo/node_configuration
  nodes = Dir[File.join(root_dir + '/chef-repo','node_configuration','*.json')]

  # Iterate over each of the JSON files that describe a node/server
  nodes.each do |file|

    node_json = JSON.parse(File.read(file))

    # only the vagrant section of the node/server description file is being processed
    if node_json["vagrant"]
      machine_name = node_json["vagrant"][":name"]

      # Allow us to remove certain items from the run_list.
      if exclusions = node_json["vagrant"]["exclusions"]
        exclusions.each do |exclusion|
          if node_json["run_list"].delete(exclusion)
            puts "removed #{exclusion} from the run list"
          end
        end
      end

      # Define multiple guest machines per Vagrantfile
      config.vm.define machine_name do |machine|

        ####################################
        ######### Port Forwarding ##########
        ####################################

        if ports = node_json["vagrant"]["ports"]
          #ports is an array of hashes
          ports.each do |port|
            # when writing the node/server description file we'll only
            # use port forwarding for public facing nodes
            machine.vm.network :forwarded_port, guest: port[":guest"], host: port[":host"]
          end # ports.each do |port|
        end # if node_json["vagrant"]["ports"]

        ####################################
        ###### Private Networking ##########
        ####################################

        # Setup a private network to allow access to guest machine by an
        # address not accessible by the public internet.

        # Use private networking with a static IP if we specified an IP. Otherwise fall back to DHCP
        if node_json["vagrant"][":ip"]
          machine.vm.network :private_network, ip: node_json["vagrant"][":ip"]
        else
          machine.vm.network :private_network, type: "dhcp"
        end # if node_json["vagrant"][":ip"]

        ####################################
        ######## Domain Management #########
        ####################################

        # Use the vagrant-hostmanager plugin to define a host name for the machine
        if node_json["vagrant"][":host"]
          machine.vm.hostname = node_json["vagrant"][":host"]
        end # node_json["vagrant"][":host"]

        ####################################
        ############# Aliases ##############
        ####################################

        # Use the vagrant-hostmanager plugin to add aliases to for the host name
        if node_json["vagrant"][":aliases"]
          machine.hostmanager.aliases = node_json["vagrant"][":aliases"]
        end # if node_json["vagrant"][":aliases"]

        ####################################
        ########### Synced Folders #########
        ####################################

        # Sync folders a folder on the host machine to the guest machine.
        # By default the project directory (folder with Vagrantfile) is shared
        # with /vagrant on the guest machine.

        if node_json["vagrant"]["synced_folder"]

          # node_json["vagrant"]["synced_folder"] is an array of hashes
          node_json["vagrant"]["synced_folder"].each do |sync|
            if sync["ownership_options"]

              # set the directory and file permissions as a variable
              dmode = sync["ownership_options"][":mount_options"][":dmode"]
              fmode = sync["ownership_options"][":mount_options"][":fmode"]

              machine.vm.synced_folder sync[":host_machine_path"], sync[":guest_machine_path"], create: true,
              owner: sync["ownership_options"][":owner"],
              group: sync["ownership_options"][":group"],
              mount_options: ["dmode=#{dmode},fmode=#{fmode}"]
            else
              machine.vm.synced_folder sync[":host_machine_path"], sync[":guest_machine_path"], create: true
            end # sync["ownership_options"]
          end # node_json["vagrant"]["synced_folder"].each do |sync|
        end # if node_json["vagrant"]["synced_folder"]

        ####################################
        ############## Providers ###########
        ####################################

        # Customize the VirtualBox Provider
        machine.vm.provider :virtualbox do |vb|
          # turn on the GUI
          # vb.gui = true
          
          # Change the VM's name
          vb.customize ["modifyvm", :id, "--name", machine_name]

          # Sets the amount of RAM, in MB, that the virtual machine should allocate for itself from the host
          if(node_json["vagrant"][":memory"])
            vb.customize ["modifyvm", :id, "--memory", node_json["vagrant"][":memory"]]
          end
        end # machine.vm.provider :virtualbox do |vb|

        ####################################
        ########### Provisioning ###########
        ####################################
        
        #Chef configuration and provisioning
        
        if ARGV.include? '--provision-with'
          machine.vm.provision "chef_solo", type: "chef_solo" do |chef|
            chef.cookbooks_path = ["chef-repo/cookbooks"]
            chef.data_bags_path = ["chef-repo/data_bags"]
            chef.environments_path = "chef-repo/environment"
            #chef.nodes_path = "chef-repo/nodes"
            chef.roles_path = "chef-repo/roles"
            chef.environment = chef_environment || "development"
            chef.node_name = machine_name
            chef.encrypted_data_bag_secret_key_path = "chef-repo/.chef/encrypted_data_bag_secret"
            chef.custom_config_path = "chef-repo/.chef/vagrant_chef_solo.rb"
            chef.provisioning_path = "/etc/chef"
            chef.log_level = :info
            chef.run_list = node_json["run_list"]
          end # machine.vm.provision "chef_solo", type: :chef_solo do |chef|
        else
          machine.vm.provision "chef_server", type: "chef_client", run: "never" do |chef|
            chef.chef_server_url = "https://api.chef.io/organizations/#{orgname}" # hosted chef url or self host a chef server
            chef.validation_key_path = "chef-repo/.chef/#{orgname}-validator.pem"
            chef.validation_client_name = "#{orgname}-validator"
            chef.environment = chef_environment || "development"
            chef.node_name = machine_name
            chef.encrypted_data_bag_secret_key_path = "chef-repo/.chef/encrypted_data_bag_secret"
            chef.provisioning_path = "/etc/chef"
            chef.log_level = :info
            chef.run_list = node_json["run_list"]
  
            #configure chef to automatically remove Chef "node" entry and Chef "client" entry on the Chef Server after tearing down guest machine
            chef.delete_node = true
            chef.delete_client = true
          end # machine.vm.provision "chef_server", type: :chef_client do |chef|
        end
      end # config.vm.define machine_name do |machine|
    end # if node_json["vagrant"]
  end # node.each do |file|
end # Vagrant.configure(2) do |config|