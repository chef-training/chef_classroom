# Cookbook Name:: chef_classroom
# Recipe:: deploy_multi_nodes

require 'chef/provisioning/aws_driver'
with_driver "aws::#{region}"
class_name = node['chef_classroom']['class_name']
student = node['chef_classroom']['student_prefix']

include_recipe 'chef_portal::_refresh_iam_creds'

machine_batch do
  action :allocate
  1.upto(count) do |i|
    machine "#{student}-#{i}-node-2" do
      machine_options create_machine_options(region, 'amzn', node_size, portal_key, 'nodes')
      tags ['node-2', "#{student}-#{i}", class_name ]
    end
    machine "#{student}-#{i}-node-3" do
      machine_options create_machine_options(region, 'windows', node_size, portal_key, 'nodes')
      tags ['node-3', "#{student}-#{i}", class_name ]
    end
  end
end

# track what chef provisioning creates (hackity hack, don't talk back)
chef_data_bag 'class_machines'

1.upto(count) do |i|
  chef_classroom_lookup "#{student}-#{i}-node-2" do
    tags [ 'node-2', "#{student}-#{i}", class_name ]
    platform 'amazon'
    guac_user 'ec2-user'
    guac_key "/root/.ssh/#{portal_key}"
  end
  chef_classroom_lookup "#{student}-#{i}-node-3" do
    tags [ 'node-3', "#{student}-#{i}", class_name ]
    platform 'windows'
    guac_user 'Administrator'
    guac_pass 'gets_polled_automatically'
  end
end

include_recipe 'chef_classroom::_refresh_portal'
