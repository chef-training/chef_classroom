# Cookbook Name:: chef_classroom
# Recipe:: server

template '/etc/opscode-manage/manage.rb' do
  source 'manage.rb.erb'
end

template '/etc/opscode/chef-server.rb' do
  source 'chef-server.rb.erb'
end

template '/etc/chef-marketplace/marketplace.rb' do
  source 'marketplace.rb.erb'
end

# TODO: for now do this manually still, will fix up and add attributes later
# bash 'setup marketplace' do
# code <<-EOH
#   chef-marketplace-ctl setup -y \
#   -u serveradmin -p PASS \
#   -f Class -l Trainer -e trainer@chef.io \
#   -o chef-training
#   EOH
# end

execute 'chef-marketplace-ctl reconfigure'
