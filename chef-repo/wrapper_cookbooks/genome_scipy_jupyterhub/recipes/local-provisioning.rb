#
# Cookbook:: genome_scipy_jupyterhub
# Recipe:: local-provisioning
#
# Copyright:: 2017, Tyrone Saunders, All Rights Reserved.

include_recipe "genome_scipy_base::base"
include_recipe "genome_scipy_github::ssh-wrapper"
include_recipe "genome_scipy_nginx::install"
include_recipe "genome_scipy_python::install"
include_recipe "genome_scipy_nodejs::install"
include_recipe "genome_scipy_supervisor::install"
include_recipe "genome_scipy_jupyterhub::selfsigned-certificate"
include_recipe "genome_scipy_jupyterhub::deploy"
