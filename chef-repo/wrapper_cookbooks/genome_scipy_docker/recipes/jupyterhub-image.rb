#
# Cookbook:: genome_scipy_docker
# Recipe:: jupyterhub-image
#
# Copyright:: 2017, Tyrone Saunders, All Rights Reserved.

# create directory for dockerfiles
directory '/etc/docker/dockerfile' do
  recursive true
  mode '0755'
  not_if {::Dir.exist?('/etc/docker/dockerfile')}
end

# pull the jupyterhub/singleuser image to use as a base image
execute "pull the jupyterhub/singleuser image" do
  command "docker pull jupyterhub/singleuser"
end

# TODO create dockerfile

# TODO build an image from the docker file