# Cookbook Name:: chef_classroom
# Recipe:: destroy_chef_server

require 'chef/provisioning/aws_driver'
with_driver "aws::#{region}"

include_recipe 'chef_portal::_refresh_iam_creds'

machine "#{class_name}-chefserver" do
  action :destroy
end
