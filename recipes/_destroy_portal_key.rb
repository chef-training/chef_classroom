# Cookbook Name:: chef_classroom
# Recipe:: _destroy_portal_key

require 'chef/provisioning/aws_driver'
with_driver "aws::#{region}"

aws_key_pair portal_key do
  action :destroy
end

file "#{ENV['HOME']}/.ssh/#{portal_key}" do
  action :delete
  backup false
end
