# Cookbook Name:: chef_classroom
# Recipe:: deploy_chef_server

require 'chef/provisioning/aws_driver'
with_driver "aws::#{region}"

include_recipe 'chef_portal::_refresh_iam_creds'

machine "#{class_name}-chefserver" do
  machine_options create_machine_options(region, 'marketplace', server_size, portal_key, 'chef_server')
  tags [ 'chefserver', class_name ]
  recipe 'chef_classroom::chef_server'
end

chef_data_bag 'class_machines'

chef_classroom_lookup "#{class_name}-chefserver" do
  tags [ 'chefserver', class_name ]
  platform 'amazon'
end

include_recipe 'chef_classroom::_refresh_portal'
