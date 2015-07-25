log_level                :info
log_location             STDOUT
node_name                "mynode"
cache_type               'BasicFile'
cache_options( :path => "#{ENV['HOME']}/.chef/checksums" )
#
profiles({
  'default' => {
    :driver => 'aws',
    :machine_options => {
      :region => 'us-east-1',
      :ssh_username => 'ec2-user',
      :convergence_options => {
        :ssl_verify_mode => :verify_none,
        :chef_version => "12.2.1"
      },
      :bootstrap_options => {
        :instance_type => 'm3.medium',
        :image_id => 'ami-1ecae776',
        :key_name => 'aws-popup-chef'
      }
    }
  }
 }
)
