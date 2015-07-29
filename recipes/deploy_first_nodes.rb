#
# Cookbook Name:: chef_classroom
# Recipe:: deploy_first_nodes
#
# Author:: Ned Harris (<nharris@chef.io>)
# Author:: George Miranda (<gmiranda@chef.io>)
# Copyright:: Copyright (c) 2015 Chef Software, Inc.
# License:: MIT
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

node1_count = node['chef_classroom']['node1_count']
name = node['chef_classroom']['class_name']

require 'chef/provisioning/aws_driver'

with_chef_server  Chef::Config[:chef_server_url],
  :client_name => Chef::Config[:node_name],
  :signing_key_filename => Chef::Config[:client_key]

aws_security_group "training-#{name}-node-sg" do
	action :create
    inbound_rules '0.0.0.0/0' => [ 22, 80, 3389, 5985, 5986 ]
end

machine_batch do
  action :allocate
  1.upto(node1_count) do |i|
    machine "#{name}-node1#{i}" do
  	  machine_options :bootstrap_options =>{
        :security_group_ids => "training-#{name}-node-sg"
      }
      tag 'node1'
	  end
  end
end

# track what chef provisioning creates
# hackity hack, don't talk back
chef_data_bag "class_machines"

1.upto(node1_count) do |i|
  ruby_block "look up node1#{i} machine object" do
    retries 6
    retry_delay 10
    block do
      aws_object = Chef::Resource::AwsInstance.get_aws_object(
        "#{name}-node1#{i}",
        run_context: run_context,
        driver: run_context.chef_provisioning.current_driver,
        managed_entry_store: Chef::Provisioning.chef_managed_entry_store(run_context.cheffish.current_chef_server)
      )
      new_item = Chef::DataBagItem.from_hash({ 'id' => "#{name}-node1#{i}", 'public_ip' => "#{aws_object.public_ip_address}", 'tags' => 'node1'})
      new_item.data_bag('class_machines')
      new_item.save
      exit(1) if aws_object.public_ip_address.to_s.empty?
    end
  end
end
#

machine "#{name}-portal" do
  converge true
end
