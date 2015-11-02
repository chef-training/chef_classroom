# Cookbook Name:: chef_classroom
# Recipe:: server

server = node['chef_classroom']['chef_server']

bash 'Setup Marketplace Chef Server' do
code <<-EOH
  chef-marketplace-ctl setup -y \
  --username #{server[:admin_user]} \
  --password #{server[:admin_pass]} \
  --firstname #{server[:first_name]} \
  --lastname #{server[:last_name]} \
  --email #{server[:e_mail]} \
  --org #{server[:default_org]}
  EOH
end
