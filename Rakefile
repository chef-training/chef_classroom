require 'rspec/core/rake_task'
require 'rubocop/rake_task'
require 'foodcritic'
require 'kitchen'
require 'net/http'

PORTAL_IP = ''

def run_command(command)
  if File.exist?('Gemfile.lock')
    sh %(bundle exec #{command})
  else
    sh %(chef exec #{command})
  end
end

task destroy_all: [:destroy_machine] do
  run_command('rm -rf Gemfile.lock && rm -rf Berksfile.lock && rm -rf cookbooks/')
end

namespace :deploy do
  desc 'Deploy Portal'
  task portal: [:berks_vendor] do
    run_command('chef-client -z -r "role[class],recipe[chef_classroom::deploy_portal]"')
  end
end

def portal_get(action)
  uri = URI.parse("http://#{PORTAL_IP}/#{action}")
  response = Net::HTTP.get_response(uri)
  puts response.inspect
end

namespace :portal do
  desc 'Refresh Portal'
  task :refresh do
    puts 'Refreshing Nodes'
    portal_get('refresh_portal')
  end

  desc 'Deploy Workstations'
  task :deploy_workstations do
    puts 'Deploy Workstations'
    portal_get('deploy_workstations')
  end

  desc 'Deploy Chef Server'
  task :deploy_chef_server do
    puts 'Deploy Additional Nodes'
    portal_get('deploy_chef_server')
  end

  desc 'Deploy First Nodes'
  task :deploy_first_nodes do
    puts 'Deploy First Nodes'
    portal_get('deploy_first_nodes')
  end

  desc 'Deploy Additional Nodes'
  task :deploy_multi_nodes do
    puts 'Deploy Additional Nodes'
    portal_get('deploy_multi_nodes')
  end

  desc 'Destroy Student Workstations'
  task :destroy_workstations do
    puts 'Destroy Student Workstations'
    portal_get('destroy_workstations')
  end

  desc 'Destroy Entire Lab'
  task :destroy_lab do
    puts 'Destroy All Nodes, Workstations, and Chef Server'
    portal_get('destroy_lab')
  end

  desc 'Destroy Chef Server'
  task :destroy_chef_server do
    puts 'Destroy Chef Server'
    portal_get('destroy_server')
  end
end

namespace :destroy do
  desc 'Destroy Portal'
  task :portal do
    run_command('chef-client -z -r "role[class],recipe[chef_classroom::destroy_portal]"')
  end
end

desc 'Vendor cookbooks'
task :berks_vendor do
  run_command('rm -rf Berksfile.lock && rm -rf cookbooks/ && berks vendor cookbooks')
end

# Style tests. Rubocop and Foodcritic
namespace :style do
  desc 'Run Ruby style checks'
  RuboCop::RakeTask.new(:ruby)

  desc 'Run Chef style checks'
  FoodCritic::Rake::LintTask.new(:chef) do |t|
    t.options = {
      fail_tags: ['any'],
      tags: ['~FC005'],
    }
  end
end

desc 'Run all style checks'
task style: ['style:chef', 'style:ruby']

# Rspec and ChefSpec
desc 'Run ChefSpec examples'
RSpec::Core::RakeTask.new(:spec)

# Integration tests. Kitchen.ci
namespace :integration do
  desc 'Run Test Kitchen with Vagrant'
  task :vagrant do
    Kitchen.logger = Kitchen.default_file_logger
    Kitchen::Config.new.instances.each do |instance|
      instance.test(:always)
    end
  end

  desc 'Run Test Kitchen with cloud plugins'
  task :cloud do
    run_kitchen = true
    if ENV['TRAVIS'] == 'true' && ENV['TRAVIS_PULL_REQUEST'] != 'false'
      run_kitchen = false
    end

    if run_kitchen
      Kitchen.logger = Kitchen.default_file_logger
      @loader = Kitchen::Loader::YAML.new(project_config: './.kitchen.cloud.yml')
      config = Kitchen::Config.new(loader: @loader)
      config.instances.each do |instance|
        instance.test(:always)
      end
    end
  end
end

desc 'Run all tests on Travis'
task travis: ['style', 'spec', 'integration:cloud']

# Default
task default: ['style', 'spec', 'integration:vagrant']
