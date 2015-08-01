#
# Cookbook Name:: chef_classroom
# Library:: helper
#
# Author:: George Miranda (<gmiranda@chef.io>)
# Author:: Scott Ford (<fords@chef.io>)
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

module ChefHelpers # Helper Module for general purposes

  # an odd recursive lookup bug prevents this one from being a good idea
  # def name
  #   node['chef_classroom']['class_name']
  # end

  def count
    node['chef_classroom']['number_of_students']
  end

  def type
    node['chef_classroom']['workstation_type']
  end

  def source
    node['chef_classroom']['ip_range']
  end

  def node_size
    node['chef_classroom']['node_size']
  end

  def portal_size
    node['chef_classroom']['portal_size']
  end

  def server_size
    node['chef_classroom']['server_size']
  end

  def workstation_size
    node['chef_classroom']['workstation_size']
  end

  # def lookup_region_ami(type)
  #   case node['chef_classroom']['region']
  #   when 'us-east-1'
  #     'ami-a1b2c3d4' if type == 'amzn'
  #     'ami-b2c3d4e5' if type == 'centos'
  #     'ami-c3d4e5f6' if type == 'windows'
  #   when 'us-west-1'
  #     'ami-a1b2c3d4' if type == 'amzn'
  #     'ami-b2c3d4e5' if type == 'centos'
  #     'ami-c3d4e5f6' if type == 'windows'
  #   when 'us-west-2'
  #     'ami-a1b2c3d4' if type == 'amzn'
  #     'ami-b2c3d4e5' if type == 'centos'
  #     'ami-c3d4e5f6' if type == 'windows'
  #   when 'eu-west-1'
  #     'ami-a1b2c3d4' if type == 'amzn'
  #     'ami-b2c3d4e5' if type == 'centos'
  #     'ami-c3d4e5f6' if type == 'windows'
  #   when 'eu-central-1'
  #     'ami-a1b2c3d4' if type == 'amzn'
  #     'ami-b2c3d4e5' if type == 'centos'
  #     'ami-c3d4e5f6' if type == 'windows'
  #   when 'ap-southeast-1'
  #     'ami-a1b2c3d4' if type == 'amzn'
  #     'ami-b2c3d4e5' if type == 'centos'
  #     'ami-c3d4e5f6' if type == 'windows'
  #   when 'ap-southeast-2'
  #     'ami-a1b2c3d4' if type == 'amzn'
  #     'ami-b2c3d4e5' if type == 'centos'
  #     'ami-c3d4e5f6' if type == 'windows'
  #   when 'ap-northeast-1'
  #     'ami-a1b2c3d4' if type == 'amzn'
  #     'ami-b2c3d4e5' if type == 'centos'
  #     'ami-c3d4e5f6' if type == 'windows'
  #   when 'sa-east-1'
  #     'ami-a1b2c3d4' if type == 'amzn'
  #     'ami-b2c3d4e5' if type == 'centos'
  #     'ami-c3d4e5f6' if type == 'windows'
  #   end
  # end

end

Chef::Recipe.send(:include, ChefHelpers)
Chef::Resource.send(:include, ChefHelpers)
