# Cookbook Name:: chef_classroom
# Recipe:: destroy_portal

require 'chef/provisioning/aws_driver'
with_driver "aws::#{region}"

machine "#{class_name}-portal" do
  action :destroy
end

aws_security_group "training-#{class_name}-portal" do
  action :destroy
end

include_recipe 'chef_classroom::_destroy_portal_key'
