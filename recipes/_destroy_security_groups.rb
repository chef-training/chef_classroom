# Cookbook Name:: chef_classroom
# Recipe:: _destroy_security_groups

require 'chef/provisioning/aws_driver'
with_driver "aws::#{region}"

%w(chef_server nodes workstations).each do |secgroup|
  aws_security_group "training-#{class_name}-#{secgroup}" do
    action :destroy
  end
end
