#
# Cookbook Name:: chef_classroom
# Recipe:: portal
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

service "iptables" do
  action [ :disable, :stop ]
end

package 'httpd'

service 'httpd' do
	supports :status => true, :restart => true, :reload => true
	action [ :start, :enable ]
end

template '/var/www/html/index.html' do
	source 'index.html.erb'
	mode '0644'
	variables({
    :workstations => search("node","tags:workstation"),
	  :node1s => search("class_machines","tags:node1"),
	  :node2s => search("class_machines","tags:node2"),
	  :node3s => search("class_machines","tags:node3"),
	  :chefserver => search("node","tags:chefserver")
  })
end

# create the guacamole user map
name = node['chef_classroom']['class_name']

usermap = Hash.new
1.upto(count).each do |i|
  usermap["#{i}"] = {
    "name" => "student#{i}",
    "password" => "chef",
    "machines" => {
      "workstation" => search("node","tags:workstation AND name:#{name}-workstation-#{i}").first,
      "node1" => search("class_machines","tags:node1 AND name:#{name}-node1-#{i}").first,
      "node2" => search("class_machines","tags:node2 AND name:#{name}-node2-#{i}").first,
      "node3" => search("class_machines","tags:node2 AND name:#{name}-node3-#{i}").first
    }
  }
end

#node.default['guacamole']['usermap'] = usermap

include_recipe 'guacamole'
