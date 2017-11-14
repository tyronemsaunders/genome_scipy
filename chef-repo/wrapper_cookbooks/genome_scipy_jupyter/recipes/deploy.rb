#
# Cookbook:: genome_scipy_jupyter
# Recipe:: deploy
#
# Copyright:: 2017, Tyrone Saunders, All Rights Reserved.

Chef::Recipe.send(:include, OpenSSLCookbook::RandomPassword)

#############
# variables #
#############
ssh_wrapper = node['secrets']['github'][node.chef_environment]
env_vars = {
  "HOME" => ::Dir.home(node['jupyter']['user']),
  "APPLICATION_MODE" => node.chef_environment.upcase
}

###############
# Directories #
###############
directory node['jupyter']['directories']['runtime'] do
  owner node['ssh']['user']
  mode '0755'
  recursive true
end

directory node['jupyter']['directories']['configuration'] do
  owner node['ssh']['user']
  mode '0770'
  recursive true
end

directory node['jupyter']['directories']['log'] do
  owner node['ssh']['user']
  mode '0755'
  recursive true
end

##############
# Deployment #
##############
# retrieve configuration details from data bag
apps = node['deploy']['jupyter'][node.chef_environment]

apps.each do |app|
  
  #############
  # variables #
  #############
  env_vars['PYTHON_PORT'] = app['port']
  subdomain = app['subdomain']
  domain = app['domain']
  port = app['port']
  force_ssl = app['ssl']
  nginx_template = app['nginx_config_template']
  cookie_secret = random_password(length: 32, mode: :hex)
  
  if subdomain == 'www'
    server_name = domain
  else
    server_name = "#{subdomain}.#{domain}"
  end
  
  ###########################
  # Deploy app (github) #
  ###########################
  repository = app['git']['repository']
  branch = app['git']['branch']
  jupyter_config = app['config']['jupyter']
  programs = app['programs']
  
  # create the directory for the application
  directory "/var/#{domain}/#{subdomain}" do
    owner node['ssh']['user']
    group 'www-data'
    mode '0775'
    action :create
    recursive true
  end
  
  ##### Deploy the web application - use synced folder if development env else use github #####
  if ['staging', 'production'].include? node.chef_environment
    git "/var/#{domain}/#{subdomain}" do
      repository repository
      revision branch
      ssh_wrapper "#{ssh_wrapper['keypair_path']}/#{ssh_wrapper['ssh_wrapper_filename']}"
      environment(
        lazy {
          {
            'HOME' => ::Dir.home(node['ssh']['user']),
            'USER' => node['ssh']['user']
          }
        }
      )
      group 'www-data'
      user node['ssh']['user']
      action :sync
    end
  end 
  
  # install apt packages
  app['apt'].each do |apt_package|
    package apt_package do
      action :upgrade
    end
  end
  
  # install npm packages
  app['npm']['global'].each do |npm_package|
     nodejs_npm npm_package
  end
  
  app['npm']['local'].each do |npm_package|
     nodejs_npm npm_package do
       path "/var/#{domain}/#{subdomain}"
     end
  end 
  
  # create a directory for the virtualenv
  directory "/var/#{domain}/#{subdomain}/.venv" do
    user 'www-data'
    group 'www-data'
    mode '0755'
    recursive true
    action :create
  end
  
  # create and activate virtual env
  python_virtualenv "/var/#{domain}/#{subdomain}/.venv" do
    python '3' # for the python runtime use the "system" version of python
    user 'www-data'
    group 'www-data'
  end
  
  # install pip packages from requirements.txt
  pip_requirements "/var/#{domain}/#{subdomain}/requirements.txt" do
    virtualenv "/var/#{domain}/#{subdomain}/.venv"
    group 'www-data'
    user node['jupyter']['user']
  end
  
  # create a kernel
  python_execute "create ipykernel" do
    python '3'
    virtualenv "/var/#{domain}/#{subdomain}/.venv"
    command "-m ipykernel install --sys-prefix --name ipykernel-#{domain}.#{subdomain} --display-name 'Python 3 (#{domain}.#{subdomain})'"
    user node['jupyter']['user']
    environment(
      lazy {
        {
          'HOME' => ::Dir.home(node['jupyter']['user']),
          'USER' => node['jupyter']['user']
        }
      }
    ) 
  end
  
  # generate the cookie secret
  file "#{node['jupyter']['directories']['runtime']}/#{subdomain}.#{domain}_cookie_secret" do
    owner node['jupyter']['user']
    mode '0600'
    content cookie_secret
  end
  
  #  jupyterhub_config.py
  template "#{node['jupyter']['directories']['configuration']}/#{subdomain}.#{domain}_config.py" do
    source "jupyter_notebook_config.py.erb"
    owner node['jupyter']['user']
    mode '0500'
    variables(
      :subdomain => subdomain,
      :domain => domain,
      :runtime_directory => node['jupyter']['directories']['runtime'],
      :ssl_directory => node['jupyter']['directories']['ssl'],
      :port => port,
      :ssl_key_filename => "ssl.key",
      :ssl_cert_filename => "ssl.pem",
      :notebook_dir => "/var/#{domain}/#{subdomain}/jupyter/notebooks"
    )
  end
  
  # run commands
  app['commands'].each do |cmd|
    execute "run #{cmd} command" do
      live_stream true
      user node['ssh']['user']
      environment(
        lazy {
          {
            'HOME' => ::Dir.home(node['ssh']['user']),
            'USER' => node['ssh']['user']
          }
        }
      )
      cwd "/var/#{domain}/#{subdomain}"
      command cmd
    end
  end
  
  # setup programs running under supervisor
  programs.each_pair do |program_name, program_config|
    # configure supervisor program scripts
    program_config['user'] = node['jupyter']['user']
    program_config['environment'] = env_vars.keys.map{|key| "#{key}=#{env_vars[key]}"}.join(",")
    
    template "/etc/supervisor/conf.d/#{program_name}.conf" do
      source "supervisor_program.conf.erb"
      variables(
        :program_name => program_name,
        :program_config => program_config
      )
    end 
  end # programs.each_pair do |program_name, program_config|
  
  # setup nginx configuration 
  nginx_site server_name do
    action :enable
    template nginx_template
    variables(
      :default => false,
      :sendfile => 'off',
      :force_ssl => force_ssl,
      :subdomain => subdomain,
      :domain => domain,
      :port => port,
      :ssl_directory => node['jupyter']['directories']['ssl']
    )
  end
end