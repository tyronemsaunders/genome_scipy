#
# Cookbook:: genome_scipy_jupyter
# Recipe:: letsencrypt
#
# Copyright:: 2017, Tyrone Saunders, All Rights Reserved.

include_recipe "acme"

apps = node['deploy']['jupyter'][node.chef_environment]

apps.each do |app|
  acme_ssl_certificate "#{app['subdomain']}.#{app['domain']}" do
    cn        "#{app['subdomain']}.#{app['domain']}"
    output    :fullchain
    crt       "#{node['jupyter']['directories']['ssl']}/#{app['subdomain']}.#{app['domain']}/ssl.pem"
    key       "#{node['jupyter']['directories']['ssl']}/#{app['subdomain']}.#{app['domain']}/ssl.key"
    wwwroot   "/var/#{app['domain']}/#{app['subdomain']}"
    webserver :nginx
    
    notifies :reload, 'service[nginx]'
  end
end