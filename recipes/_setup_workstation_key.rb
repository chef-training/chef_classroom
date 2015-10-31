# Cookbook Name:: chef_classroom
# Recipe:: _setup_workstation_key

require 'chef/provisioning/aws_driver'
with_driver "aws::#{region}"

aws_key_pair workstation_key do
  allow_overwrite false
  private_key_path "#{ENV['HOME']}/.ssh/#{workstation_key}"
end
