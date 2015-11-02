# Cookbook Name:: chef_classroom
# Recipe:: default

include_recipe 'chef_portal::_refresh_iam_creds'
include_recipe 'chef_classroom::_setup_security_groups'
include_recipe 'chef_classroom::deploy_workstations'
include_recipe 'chef_classroom::deploy_first_nodes'
include_recipe 'chef_classroom::deploy_chef_server'
include_recipe 'chef_classroom::deploy_multi_nodes'
