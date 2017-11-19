#
# Cookbook:: genome_scipy_aws
# Recipe:: monolith
#
# Copyright:: 2017, Tyrone Saunders, All Rights Reserved.

require "chef/provisioning/aws_driver"
with_driver "aws::#{node['secrets']['aws']['region']}"

# when deploying multiple programs to an EC2 instance assume all programs have the same domain
apps = node['deploy']['app'][node.chef_environment]
app = apps.first

######################
# Setup EC2 instance #
######################
machine "genome-scipy.#{app['domain']}" do
  # copy chef data bag secret
  files "/etc/chef/encrypted_data_bag_secret" => "#{node['secrets']['host_machine']['project_path']}/#{node['secrets']['data_bag']['relative_path']}"
  chef_environment node.chef_environment
  machine_options({
    bootstrap_options: {
      image_id: node['secrets']['aws']['image_id'], # Ubuntu 16.04 LTS - Xenial (HVM) (US East N. Virginia)
      instance_type: node['secrets']['aws']['instance_type'],
      key_name: node['secrets']['aws']['aws_key_name'],
      key_path: node['secrets']['aws']['aws_key_path'],
      security_group_ids: ["webserver"],
      block_device_mappings: [
        {
          device_name: "/dev/sda1",
          ebs: {
            volume_size: 64
          }
        }
      ]
    },
    convergence_options: {
      chef_version: node['chef_client']['version']
    }
  }) 
end

elastic_ip = aws_eip_address "genome-scipy.#{app['domain']}" do
  machine "genome-scipy.#{app['domain']}"
end

machine "genome-scipy.#{app['domain']}" do
  chef_environment node.chef_environment
  # set attributes
  attributes({
    :aws => {
      :elastic_ip => elastic_ip.aws_object.public_ip
    }
  })
  # recipe run list
  recipe "genome_scipy_base::base"
  recipe "genome_scipy_hosts::hosts"
  recipe "genome_scipy_github::ssh-wrapper"
  recipe "genome_scipy_nginx::install"
  recipe "genome_scipy_python::install"
  recipe "genome_scipy_nodejs::install"
  recipe "genome_scipy_supervisor::install"
  recipe "genome_scipy_docker::install"
  recipe "genome_scipy_jupyterhub::selfsigned-certificate"
  recipe "genome_scipy_jupyterhub::deploy"
  recipe "genome_scipy_jupyterhub::letsencrypt"
  recipe "genome_scipy_jupyter::selfsigned-certificate"
  recipe "genome_scipy_jupyter::deploy"
  recipe "genome_scipy_jupyter::letsencrypt"
  recipe "genome_scipy_app::selfsigned-certificate"
  recipe "genome_scipy_app::deploy"
  recipe "genome_scipy_app::letsencrypt"
  recipe "genome_scipy_supervisor::restart"
  machine_options({
    convergence_options: {
      chef_version: node['chef_client']['version']
    }
  })
end
