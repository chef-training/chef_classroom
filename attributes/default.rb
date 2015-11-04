# for each class, all students get:
# 1 pre-configured workstation (amzn)
# 1 initial node to manage (centos)
# 2 additional nodes when multi-node is taught (1 centos, 1 windows)
default['chef_classroom']['class_name'] = 'mytraining'
default['chef_classroom']['number_of_students'] = 2
default['chef_classroom']['student_prefix'] = 'student'
default['chef_classroom']['ip_range'] = '0.0.0.0/0'

default['chef_classroom']['chef_server'].tap do |chef|
  chef['admin_user'] = 'instructor'
  chef['admin_pass'] = 'instructor_pass'
  chef['first_name'] = 'Chef'
  chef['last_name'] = 'Instructor'
  chef['e_mail'] = 'training-chef@chef.io'
  chef['default_org'] = 'chef-training'
end

# regional aws settings
default['chef_classroom']['region'] = 'us-east-1'
default['chef_classroom']['iam_instance_profile'] = 'arn:aws:iam::567812349012:instance-profile/provisioner'
default['chef_classroom']['role_json'] = 'roles/class.json'
default['chef_classroom']['chef_version'] = '12.5.1'

# tweak workstation_type (only current option is linux -- roadmap: add windows)
default['chef_classroom']['workstation_type'] = 'linux'

# tweak instance sizes
default['chef_classroom']['linux']['workstation_size'] = 't2.medium'
default['chef_classroom']['linux']['node_size'] = 't2.micro'

default['chef_classroom']['windows']['workstation_size'] = 'c4.large'
default['chef_classroom']['windows']['node_size'] = 'm3.medium'

default['chef_classroom']['portal_size'] = 'm3.medium'
default['chef_classroom']['chef_server_size'] = 'm3.medium'
