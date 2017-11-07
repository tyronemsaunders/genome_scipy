# Cookbook Name:: genome_scipy_base
# Attribute:: default
#
# Copyright 2017, Tyrone Saunders. All Rights Reserved.

#####################
# env specific vars #
#####################
if ["development"].include?(node.chef_environment)
  default['ssh']['user'] = 'vagrant'
elsif ["staging"].include?(node.chef_environment)
  default['ssh']['user'] = 'ubuntu'  
else
  default['ssh']['user'] = 'ubuntu'
end

###############################
# user/owner for applications #
###############################
default['app']['user'] = "www-data"

#########################
# Environment variables #
#########################
default['environment']['variables'] = {}
default['environment']['variables']["APPLICATION_MODE"] = node.chef_environment.upcase
default['environment']['variables']["XDG_CONFIG_DIRS"] = "/etc/xdg/.config"
default['environment']['variables']["APP_SECRETS_PATH"] = "$XDG_CONFIG_DIRS"
default['environment']['variables']["AWS_SHARED_CREDENTIALS_FILE"] = "$XDG_CONFIG_DIRS/.aws/credentials"
# literal
default['env']['vars'] = {}
default['env']['vars']["APPLICATION_MODE"] = node.chef_environment.upcase
default['env']['vars']["XDG_CONFIG_DIRS"] = "/etc/xdg/.config"
default['env']['vars']["APP_SECRETS_PATH"] = node['env']['vars']['XDG_CONFIG_DIRS']
default['env']['vars']["AWS_SHARED_CREDENTIALS_FILE"] = "#{node['env']['vars']['XDG_CONFIG_DIRS']}/.aws/credentials"

####################
# Data Bag Secrets #
####################
if Chef::Config[:solo] 
  default['secrets']['aws'] = Chef::DataBagItem.load('secrets', 'aws')
  default['secrets']['github'] = Chef::DataBagItem.load('secrets', 'github')
  default['secrets']['data_bag'] = Chef::DataBagItem.load('secrets', 'data_bag')
  default['secrets']['host_machine'] = Chef::DataBagItem.load('secrets', 'host_machine')  
else
  default['secrets']['aws'] = Chef::EncryptedDataBagItem.load('secrets', 'aws')
  default['secrets']['github'] = Chef::EncryptedDataBagItem.load('secrets', 'github')
  default['secrets']['data_bag'] = Chef::EncryptedDataBagItem.load('secrets', 'data_bag')
  default['secrets']['host_machine'] = Chef::EncryptedDataBagItem.load('secrets', 'host_machine')  
end
##########################
# Un-encrypted Data Bags #
##########################
default['deploy']['app'] = Chef::DataBagItem.load('deploy', 'app')
