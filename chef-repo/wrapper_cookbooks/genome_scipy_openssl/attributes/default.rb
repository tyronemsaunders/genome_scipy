# Cookbook Name:: genome_scipy_openssl
# Attribute:: default
#
# Copyright 2017, Tyrone Saunders. All Rights Reserved.

###############################
# Un-Encrypted Data Bag Items #
###############################
default['deploy']['app'] = Chef::DataBagItem.load('deploy', 'app')

####################
# Data Bag Secrets #
####################
if Chef::Config[:solo] 
  default['secrets']['openssl'] = Chef::DataBagItem.load('secrets', 'openssl')
else
  default['secrets']['openssl'] = Chef::EncryptedDataBagItem.load('secrets', 'openssl')
end