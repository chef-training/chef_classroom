#
# Cookbook Name:: chef_classroom
# Provider:: object_lookup
#
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

action :lookup do
  object = new_resource.name

  ruby_block "Looking up #{object} machine object" do
    retries 6
    retry_delay 10
    block do
      aws_object = Chef::Resource::AwsInstance.get_aws_object(
        object,
        run_context: run_context,
        driver: run_context.chef_provisioning.current_driver,
        managed_entry_store: Chef::Provisioning.chef_managed_entry_store(run_context.cheffish.current_chef_server)
      )
      exit(1) if aws_object.public_ip_address.to_s.empty?
      # only create data_bag_item if there's useable data
      new_item = Chef::DataBagItem.from_hash({
        'id' => object,
        'name' => object,
        'ec2' => {
          'public_hostname' => "#{aws_object.public_dns_name}",
          'public_ipv4' => "#{aws_object.public_ip_address}",
          'private_ipv4' => "#{aws_object.private_ip_address}"
        },
        'platform_family' => "#{new_resource.platform}",
        'guacamole_user' => 'chef',
        'guacamole_pass' => 'chef',
        'tags' => "#{new_resource.tag}"
      })
      new_item.data_bag('class_machines')
      new_item.save
    end
  end
end
