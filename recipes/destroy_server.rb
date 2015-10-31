# Cookbook Name:: chef_classroom
# Recipe:: destroy_server

require 'chef/provisioning/aws_driver'
with_driver "aws::#{region}"
name = node['chef_classroom']['class_name']

include_recipe 'chef_portal::_refresh_iam_creds'

machine "#{name}-chefserver" do
  action :destroy
end
