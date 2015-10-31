# Cookbook Name:: chef_classroom
# Recipe:: deploy_workstations

require 'chef/provisioning/aws_driver'
with_driver "aws::#{region}"
name = node['chef_classroom']['class_name']
student = node['chef_classroom']['student_prefix']

include_recipe 'chef_portal::_refresh_iam_creds'

machine_batch do
  action :destroy
  machines 1.upto(count).map { |i| "#{student}-#{i}-workstation" }
end

include_recipe 'chef_classroom::_refresh_portal'
