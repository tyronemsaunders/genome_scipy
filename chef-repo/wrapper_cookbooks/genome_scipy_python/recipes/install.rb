#
# Cookbook:: genome_scipy_python
# Recipe:: install
#
# Copyright:: 2017, Tyrone Saunders, All Rights Reserved.

#######################################
# Install Python, pip, and virtualenv #
#######################################
python_runtime '2' do
  version '2.7'
  setuptools_version '35.0.2'
  provider :system
  action :install
end

python_runtime_options '2' do
  dev_package true
end
