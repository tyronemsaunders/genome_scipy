# Cookbook Name:: genome_scipy_jupyter
# Attribute:: default
#
# Copyright 2017, Tyrone Saunders. All Rights Reserved.

####################
# Data Bag Secrets #
####################
if Chef::Config[:solo]
  default['secrets']['aws'] = Chef::DataBagItem.load('secrets', 'aws')
  default['secrets']['github'] = Chef::DataBagItem.load('secrets', 'github')
  default['secrets']['ssh_keys'] = Chef::DataBagItem.load('secrets', 'ssh_keys')
  default['secrets']['data_bag'] = Chef::DataBagItem.load('secrets', 'data_bag')
  default['secrets']['host_machine'] = Chef::DataBagItem.load('secrets', 'host_machine')  
  default['secrets']['openssl'] = Chef::DataBagItem.load('secrets', 'openssl')
else
  default['secrets']['aws'] = Chef::EncryptedDataBagItem.load('secrets', 'aws')
  default['secrets']['github'] = Chef::EncryptedDataBagItem.load('secrets', 'github')
  default['secrets']['ssh_keys'] = Chef::EncryptedDataBagItem.load('secrets', 'ssh_keys')
  default['secrets']['data_bag'] = Chef::EncryptedDataBagItem.load('secrets', 'data_bag')
  default['secrets']['host_machine'] = Chef::EncryptedDataBagItem.load('secrets', 'host_machine') 
  default['secrets']['openssl'] = Chef::EncryptedDataBagItem.load('secrets', 'openssl')
end

##########################
# Un-encrypted Data Bags #
##########################
default['deploy']['jupyter'] = Chef::DataBagItem.load('deploy', 'jupyter')

default['jupyter']['user'] = node['ssh']['user']
default['jupyter']['directories']['runtime'] = '/srv/jupyter'
default['jupyter']['directories']['configuration'] = '/etc/jupyter'
default['jupyter']['directories']['ssl'] = "#{node['jupyter']['directories']['runtime']}/ssl"
default['jupyter']['directories']['log'] = '/var/log/jupyter'