# Cookbook Name:: chef_classroom
# Recipe:: deploy_portal

require 'chef/provisioning/aws_driver'
with_driver "aws::#{region}"

# the portal will need this data_bag during the initial setup run
chef_data_bag 'class_machines'

include_recipe 'chef_classroom::_setup_portal_key'

aws_security_group "training-#{class_name}-portal" do
  action :create
  ignore_failure true
  inbound_rules class_source_addr => [22, 80, 8080]
end

machine "#{class_name}-portal" do
  machine_options create_machine_options(region, 'centos', portal_size, portal_key, 'portal')
  role   'class'
  recipe 'chef_portal::fundamentals_3x'
  converge true
end

machine_file "/root/chef_classroom/roles/class.json" do
  machine "#{class_name}-portal"
  local_path node['chef_classroom']['role_json']
  action :upload
end

# Get the newly generated key that we created to the portal machine
machine_file "/root/.ssh/#{portal_key}" do
  machine "#{class_name}-portal"
  local_path "#{ENV['HOME']}/.ssh/#{portal_key}"
  action :upload
end
