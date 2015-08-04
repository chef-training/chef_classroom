# for each class, all students get:
# 1 pre-configured workstation (amzn)
# 1 initial node to manage (centos)
# 2 additional nodes when multi-node is taught (1 centos, 1 windows)
default['chef_classroom']['class_name'] = 'mytraining'
default['chef_classroom']['number_of_students'] = 2
default['chef_classroom']['ip_range'] = '0.0.0.0/0'

# regional aws settings
default['chef_classroom']['region'] = 'us-east-1'
default['chef_classroom']['iam_instance_profile'] = 'arn:aws:iam::458523137226:instance-profile/provisioner'

# tweak workstation_type (only current option is linux -- roadmap: add windows)
default['chef_classroom']['workstation_type'] = 'linux'

# tweak instance sizes
default['chef_classroom']['workstation_size'] = 't2.medium'
default['chef_classroom']['node_size'] = 't2.micro'
default['chef_classroom']['portal_size'] = 'm3.medium'
default['chef_classroom']['chef_server_size'] = 'm3.medium'
