#
# Cookbook Name:: chef_classroom
# Recipe:: deploy_portal
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

# the portal will need this data_bag during the initial setup run
chef_data_bag 'class_machines'

include_recipe 'chef_classroom::_setup_workstation_key'

aws_security_group "training-#{name}-portal" do
  action :create
  ignore_failure true
  inbound_rules class_source_addr => [22, 80, 8080]
end

machine "#{name}-portal" do
  machine_options create_machine_options(region, 'centos', portal_size, workstation_key, 'portal')
  recipe 'chef_portal::fundamentals_3x'
  converge true
end

# TODO: There seems like there is a workstation key
# TODO: There also seems to be some reason that we have workstation key and portal key
#        and I think that I am the problem in naming that issue
key_name = "#{name}-workstation_key"

# Get the newly generated key that we created to the portal machine
machine_file "/root/.ssh/#{name}-portal_key" do
  machine "#{name}-portal"
  local_path "#{ENV['HOME']}/.ssh/#{key_name}"
  action :upload
end
