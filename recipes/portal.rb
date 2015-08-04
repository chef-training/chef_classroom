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

service 'iptables' do
  action [:disable, :stop]
end

package 'httpd'

service 'httpd' do
  supports :status => true, :restart => true, :reload => true
  action [:start, :enable]
end

template '/var/www/html/index.html' do
  source 'index.html.erb'
  mode '0644'
  variables({
    :workstations => search('node', 'tags:workstation'),
    :node1s => search('class_machines', 'tags:node1'),
    :node2s => search('class_machines', 'tags:node2'),
    :node3s => search('class_machines', 'tags:node3'),
    :chefserver => search('node', 'tags:chefserver')
  })
end

# here's some ugliness.  we need to get the aws ssh private key on the portal
# node to enable guacamole connections.  but that's okay because once issue #15
# is resolved, we get this on the portal for free
template "/root/.ssh/#{ssh_key}" do
  source 'ssh_key.erb'
  owner 'root'
  group 'root'
  mode '0600'
end

# lazy create the guacamole user map and monkeypatch it
# search returns nil during compilation
include_recipe 'guacamole'

chef_gem 'chef-rewind'
require 'chef/rewind'

rewind 'template[/etc/guacamole/user-mapping.xml]' do
  variables(
    lazy do
      { :usermap => guacamole_user_map }
    end
  )
end
