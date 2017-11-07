# See https://docs.chef.io/config_rb_solo.html for more information on configuration options

current_dir                  = File.dirname(__FILE__)
  
  solo                       true
  user                       = ENV['OPSCODE_USER'] || ENV['USER']
  log_level                  :warn
  log_location               STDOUT
  node_name                  user
  data_bag_encrypt_version   2
  encrypted_data_bag_secret  "#{current_dir}/encrypted_data_bag_secret"
  chef_repo_path             "../#{current_dir}"
  cookbook_path              [
                              "#{current_dir}/../cookbooks"
                             ]
  cookbook_copyright         "Tyrone Saunders"
  cookbook_license           ""
  cookbook_email             ""