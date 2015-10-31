# Cookbook Name:: chef_classroom
# Recipe:: destroy_portal

require 'chef/provisioning/aws_driver'
with_driver "aws::#{region}"
name = node['chef_classroom']['class_name']

machine "#{name}-portal" do
  action :destroy
end

aws_security_group "training-#{name}-portal" do
  action :destroy
end

include_recipe 'chef_classroom::_destroy_workstation_key'
