#
# Cookbook Name:: chef_classroom
# Recipe:: deploy
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

count = node['chef_classroom']['workstation_count']
name = node['chef_classroom']['class_name']

require 'chef/provisioning/aws_driver'

with_chef_server  Chef::Config[:chef_server_url],
  :client_name => Chef::Config[:node_name],
  :signing_key_filename => Chef::Config[:client_key]

aws_security_group "training-#{name}-workstation-sg" do
	action :create
    inbound_rules '0.0.0.0/0' => [ 22, 80 ]
end

aws_security_group "training-#{name}-portal-sg" do
	action :create
    inbound_rules '0.0.0.0/0' => [ 22, 80 ]
end

machine_batch do
  1.upto(count) do |i|
    machine "#{name}-workstation#{i}" do
  	  machine_options :bootstrap_options =>{
        :security_group_ids => "chef-#{name}-workstation-sg"
      }
  	  recipe 'chef_workstation::full_stack'
	  end
  end
end

machine "#{name}-portal" do
  machine_options :bootstrap_options =>{
      :security_group_ids => "chef-#{name}-portal-sg"
      }
  recipe 'chef_classroom::portal'
end
