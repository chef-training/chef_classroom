#
# Cookbook Name:: chef_classroom
# Recipe:: destroy_nodes
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

name = node['chef_classroom']['class_name']
node1_count = node['chef_classroom']['node1_count']
node2_count = node['chef_classroom']['node2_count']
node3_count = node['chef_classroom']['node3_count']

require 'chef/provisioning/aws_driver'

with_chef_server  Chef::Config[:chef_server_url],
  :client_name => Chef::Config[:node_name],
  :signing_key_filename => Chef::Config[:client_key]

machine_batch do
  action :destroy
  machines 1.upto(node1_count).map { |i| "#{name}-node1#{i}" }
  machines 1.upto(node2_count).map { |i| "#{name}-node2#{i}" }
  machines 1.upto(node3_count).map { |i| "#{name}-node3#{i}" }
end

chef_data_bag "class_machines" do
  action :delete
end

aws_security_group "training-#{name}-node-sg" do
  action :destroy
end
