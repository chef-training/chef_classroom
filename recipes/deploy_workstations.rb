# Cookbook Name:: chef_classroom
# Recipe:: deploy_workstations

require 'chef/provisioning/aws_driver'
with_driver "aws::#{region}"

# we need this data_bag during compile
chef_data_bag 'class_machines' do
  action :nothing
end.run_action(:create)

# setup base aws dependencies
include_recipe 'chef_portal::_refresh_iam_creds'
include_recipe 'chef_classroom::_setup_portal_key'
include_recipe 'chef_classroom::_setup_security_groups'

machine_batch do
  1.upto(count) do |i|
    machine "#{student}-#{i}-workstation" do
      machine_options create_machine_options(region, 'amzn', workstation_size, portal_key, 'workstations')
      tags [ 'workstation', "#{student}-#{i}", class_name ]
      recipe 'chef_workstation::full_stack'
      attribute 'guacamole_user', 'chef'
      attribute 'guacamole_pass', 'chef'
    end
  end
end

chef_data_bag 'class_machines'

1.upto(count) do |i|
  chef_classroom_lookup "#{student}-#{i}-workstation" do
    tags [ 'workstation', "#{student}-#{i}", class_name ]
    platform 'amazon'
  end
end

include_recipe 'chef_classroom::_refresh_portal'
