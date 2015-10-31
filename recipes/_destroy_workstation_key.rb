# Cookbook Name:: chef_classroom
# Recipe:: _destroy_workstation_key

require 'chef/provisioning/aws_driver'
with_driver "aws::#{region}"

aws_key_pair workstation_key do
  action :destroy
end

file "#{ENV['HOME']}/.ssh/#{workstation_key}" do
  action :delete
  backup false
end
