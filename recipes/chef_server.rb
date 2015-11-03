# Cookbook Name:: chef_classroom
# Recipe:: chef_server

chef_server = node['chef_classroom']['chef_server']

execute 'Setup Marketplace Chef Server' do
  command <<-EOH
  chef-marketplace-ctl setup -y \
  --username #{chef_server['admin_user']} \
  --password #{chef_server['admin_pass']} \
  --firstname #{chef_server['first_name']} \
  --lastname #{chef_server['last_name']} \
  --email #{chef_server['e_mail']} \
  --org #{chef_server['default_org']}
  EOH
end
