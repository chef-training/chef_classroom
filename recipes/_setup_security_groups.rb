#
# Cookbook Name:: chef_classroom
# Recipe:: _setup_security_groups
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

require 'chef/provisioning/aws_driver'
with_driver "aws::#{region}"
name = node['chef_classroom']['class_name']

# aws_security_group "training-#{name}-portal" do
#   action :create
#   inbound_rules class_source_addr => [22, 80, 8080]
# end

aws_security_group "training-#{name}-workstations" do
  action :create
  inbound_rules class_source_addr         => [22],
                node['ec2']['local_ipv4'] => [22]   if type == 'linux'
                # "training-#{name}-portal" => [22]   if type == 'linux'
  inbound_rules class_source_addr         => [3389],
                node['ec2']['local_ipv4'] => [22]   if type == 'windows'
                # "training-#{name}-portal" => [3389] if type == 'windows'
end

aws_security_group "training-#{name}-nodes" do
  action :create
  inbound_rules "training-#{name}-workstations" => [22, 5985, 5986],
                node['ec2']['local_ipv4']       => [22, 5985, 5986],
                # "training-#{name}-portal"       => [22, 5985, 5986], # for bootstrapping from portal
                class_source_addr               => [22, 5985, 5986] # until portal does bootstrapping
end

aws_security_group "training-#{name}-chef_server" do
  action :create
  inbound_rules class_source_addr         => [22, 80, 443], # 22 only until portal does bootstrapping
                "training-#{name}-nodes"  => [443],
                node['ec2']['local_ipv4'] => [22],
                # "training-#{name}-portal" => [22] # for bootstrapping from portal
end
