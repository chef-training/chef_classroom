# Cookbook Name:: chef_classroom
# Recipe:: deploy_server

require 'chef/provisioning/aws_driver'
with_driver "aws::#{region}"
name = node['chef_classroom']['class_name']

include_recipe 'chef_portal::_refresh_iam_creds'

machine "#{name}-chefserver" do
  machine_options create_machine_options(region, 'marketplace', server_size, portal_key, 'chef_server')
  tag 'chefserver'
  recipe 'chef_classroom::server'
end

include_recipe 'chef_classroom::_refresh_portal'
