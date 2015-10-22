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
  #
  # an odd recursive lookup bug prevents this one from being a good idea
  # def name
  #   node['chef_classroom']['class_name']
  # end
  #
  def count
    node['chef_classroom']['number_of_students']
  end

  def type
    node['chef_classroom']['workstation_type']
  end

  def class_source_addr
    node['chef_classroom']['ip_range']
  end

  def node_size
    node['chef_classroom']['node_size']
  end

  def portal_size
    node['chef_classroom']['portal_size']
  end

  def region
    node['chef_classroom']['region']
  end

  def portal_key
    node['chef_classroom']['class_name'] + '-portal_key'
  end

  def workstation_key
    node['chef_classroom']['class_name'] + '-workstation_key'
  end

  def server_size
    node['chef_classroom']['chef_server_size']
  end

  def workstation_size
    node['chef_classroom']['workstation_size']
  end

  def lookup_region_ami(region, type)
    case region

    when 'us-east-1'
      case type
      when 'amzn'
        'ami-1ecae776'
      when 'centos'
        'ami-c2a818aa'
      when 'windows'
        'ami-f70cdd9c'
      when 'marketplace'
        'ami-0d2ce366'
      end

    when 'us-west-1'
      case type
      when 'amzn'
        'ami-d114f295'
      when 'centos'
        'ami-57cfc412'
      when 'windows'
        'ami-c751a283'
      when 'marketplace'
        'ami-3509f971'
      end

    when 'us-west-2'
      case type
      when 'amzn'
        'ami-e7527ed7'
      when 'centos'
        'ami-81d092b1'
      when 'windows'
        'ami-5b57556b'
      when 'marketplace'
        'ami-0b42423b'
      end
    #
    # when 'eu-west-1'
    #   case type
    #   when 'amzn'
    #     'ami-a1b2c3d4'
    #   when 'centos'
    #     'ami-b2c3d4e5'
    #   when 'windows'
    #     'ami-c3d4e5f6'
    #   when 'marketplace'
    #     'ami-d4e5f6g7'
    #   end
    #
    # when 'eu-central-1'
    #   case type
    #   when 'amzn'
    #     'ami-a1b2c3d4'
    #   when 'centos'
    #     'ami-b2c3d4e5'
    #   when 'windows'
    #     'ami-c3d4e5f6'
    #   when 'marketplace'
    #     'ami-d4e5f6g7'
    #   end
    #
    # when 'ap-southeast-1'
    #   case type
    #   when 'amzn'
    #     'ami-a1b2c3d4'
    #   when 'centos'
    #     'ami-b2c3d4e5'
    #   when 'windows'
    #     'ami-c3d4e5f6'
    #   when 'marketplace'
    #     'ami-d4e5f6g7'
    #   end
    #
    # when 'ap-southeast-2'
    #   case type
    #   when 'amzn'
    #     'ami-a1b2c3d4'
    #   when 'centos'
    #     'ami-b2c3d4e5'
    #   when 'windows'
    #     'ami-c3d4e5f6'
    #   when 'marketplace'
    #     'ami-d4e5f6g7'
    #   end
    #
    # when 'ap-northeast-1'
    #   case type
    #   when 'amzn'
    #     'ami-a1b2c3d4'
    #   when 'centos'
    #     'ami-b2c3d4e5'
    #   when 'windows'
    #     'ami-c3d4e5f6'
    #   when 'marketplace'
    #     'ami-d4e5f6g7'
    #   end
    #
    # when 'sa-east-1'
    #   case type
    #   when 'amzn'
    #     'ami-a1b2c3d4'
    #   when 'centos'
    #     'ami-b2c3d4e5'
    #   when 'windows'
    #     'ami-c3d4e5f6'
    #   when 'marketplace'
    #     'ami-d4e5f6g7'
    #   end
    #
    end
  end

  def lookup_ami_user(type)
    case type
    when 'amzn'
      'ec2-user'
    when 'centos'
      'root'
    when 'windows'
      'Administrator'
    when 'marketplace'
      'ec2-user'
    end
  end

  def create_machine_options(region, type, size, ssh_key, group)
    options = {
      :region => region,
      :ssh_username => lookup_ami_user(type),
      :convergence_options => {
        :ssl_verify_mode => :verify_none,
        :chef_version => '12.2.1'
      },
      :bootstrap_options => {
        :instance_type => size,
        :image_id => lookup_region_ami(region, type),
        :key_name => ssh_key,
        :security_group_ids => "training-#{node['chef_classroom']['class_name']}-#{group}"
      }
    }
    if type == 'windows'
      options[:is_windows] = true
    end
    if group == 'portal'
      options[:bootstrap_options][:iam_instance_profile] = { :arn => node['chef_classroom']['iam_instance_profile'] }
    end
    unless group == 'portal'
      options[:use_private_ip_for_ssh] = true
    end
    options
  end

  def validate_data_bag_item(item)
    Chef::DataBagItem.load('class_machines', item)
  rescue Net::HTTPServerException => error
    nil if error.response.code == '404'
  end

  def guacamole_user_map
    name = node['chef_classroom']['class_name']
    usermap = {}
    1.upto(count).each do |i|
      workstation = search(
        'node', "tags:workstation AND name:#{name}-workstation-#{i}"
      ).first
      # search returns an oddly formatted result here, load individual items instead
      node1 = validate_data_bag_item("#{name}-node1-#{i}")
      node2 = validate_data_bag_item("#{name}-node2-#{i}")
      node3 = validate_data_bag_item("#{name}-node3-#{i}")
      usermap[i] = {
        'name' => "student#{i}",
        'password' => 'chef',
        'machines' => {}
      }
      # only populate the machines hash with nodes that already exist
      usermap[i]['machines']['workstation'] = workstation unless workstation.nil?
      usermap[i]['machines']['node1'] = node1 unless node1.nil?
      usermap[i]['machines']['node2'] = node2 unless node2.nil?
      usermap[i]['machines']['node3'] = node3 unless node3.nil?
    end
    usermap
  end

  def iam_role_name
    node['chef_classroom']['iam_instance_profile'].split('/')[1]
  end
end

Chef::Recipe.send(:include, ChefHelpers)
Chef::Resource.send(:include, ChefHelpers)
