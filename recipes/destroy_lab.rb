# Cookbook Name:: chef_classroom
# Recipe:: destroy_lab

include_recipe 'chef_portal::_refresh_iam_creds'
include_recipe 'chef_classroom::destroy_workstations'
include_recipe 'chef_classroom::destroy_nodes'
include_recipe 'chef_classroom::destroy_chef_server'
include_recipe 'chef_classroom::_destroy_security_groups'
include_recipe 'chef_classroom::_destroy_portal_key'
