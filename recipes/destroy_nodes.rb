# Cookbook Name:: chef_classroom
# Recipe:: destroy_nodes

require 'chef/provisioning/aws_driver'
with_driver "aws::#{region}"

include_recipe 'chef_portal::_refresh_iam_creds'

machine_batch do
  action :destroy
  machines 1.upto(count).map { |i| "#{student}-#{i}-node-1" }
  machines 1.upto(count).map { |i| "#{student}-#{i}-node-2" }
  machines 1.upto(count).map { |i| "#{student}-#{i}-node-3" }
end

chef_data_bag 'class_machines' do
  action :delete
end
