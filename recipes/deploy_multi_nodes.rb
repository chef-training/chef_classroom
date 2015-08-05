#
# Cookbook Name:: chef_classroom
# Recipe:: deploy_multi_nodes
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

include_recipe 'chef_portal::_refresh_iam_creds'

machine_batch do
  action :allocate
  1.upto(count) do |i|
    machine "#{name}-node2-#{i}" do
      machine_options create_machine_options(region, 'amzn', node_size, portal_key, 'nodes')
      tag 'node2'
    end
    machine "#{name}-node3-#{i}" do
      machine_options create_machine_options(region, 'windows', node_size, portal_key, 'nodes')
      tag 'node3'
    end
  end
end

# track what chef provisioning creates (hackity hack, don't talk back)
chef_data_bag 'class_machines'

1.upto(count) do |i|
  chef_classroom_lookup "#{name}-node2-#{i}" do
    tag 'node2'
    platform 'rhel'
    guac_user 'ec2-user'
    guac_key "/root/.ssh/#{ssh_key}"
  end
  chef_classroom_lookup "#{name}-node3-#{i}" do
    tag 'node3'
    platform 'windows'
    guac_user 'Administrator'
    guac_pass 'gets_polled_automatically'
  end
end
#

include_recipe 'chef_classroom::_refresh_portal'
