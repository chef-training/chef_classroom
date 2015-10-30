#
# Cookbook Name:: chef_classroom
# Provider:: lookup
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
      # exit so that we only create data_bag_item if there's useable data
      #
      # the idea with this resource is to mock up something that looks like
      # an actual node oject for nodes that are not managed by chef
      new_item = Chef::DataBagItem.from_hash({
        'id' => object,
        'name' => object,
        'ec2' => {
          'public_hostname' => aws_object.public_dns_name,
          'local_hostname' => aws_object.private_dns_name,
          'public_ipv4' => aws_object.public_ip_address,
          'private_ipv4' => aws_object.private_ip_address
        },
        'platform' => new_resource.platform,
        'guacamole_user' => new_resource.guac_user,
        'guacamole_pass' => new_resource.guac_pass,
        'guacamole_key' => new_resource.guac_key,
        'tags' => new_resource.tags
      })
      new_item.data_bag('class_machines')
      new_item.save
    end
  end
  new_resource.updated_by_last_action(true)
end
