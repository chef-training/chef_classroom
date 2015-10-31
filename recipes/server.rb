# Cookbook Name:: chef_classroom
# Recipe:: server

execute 'chef-server-ctl install opscode-manage' do
  creates '/etc/yum.repos.d/chef-stable.repo'
end

%w(opscode-manage opscode).each do |dir|
  directory dir
end

template '/etc/opscode-manage/manage.rb' do
  source 'manage.rb.erb'
end

template '/etc/opscode/chef-server.rb' do
  source 'chef-server.rb.erb'
end

execute 'chef-server-ctl reconfigure' do
  creates '/etc/opscode/pivotal.pem'
end

execute 'opscode-manage-ctl reconfigure' do
  creates '/etc/opscode-manage/secrets.rb'
end
