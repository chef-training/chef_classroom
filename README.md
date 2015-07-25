# chef_classroom

## Pre-Requisites

In order to use this repo, you must have the following setup:

* Install ChefDK 0.6.2
* Update chef-provisioning to 1.2.1
* Update chef-provisioning-aws to 1.3.0

## Usage

To set up a Chef Training Classroom, do the following:

1) Create your `~/.aws/config` file if you don't already have one.  It should have content similar to:

    [default]
    aws_access_key_id = AKIAAABBCCDDEEFFGGHH
    aws_secret_access_key = "Abc0123dEf4GhIjk5lMn/OpQrSTUvXyz/A678bCD"

Except with your own AWS API credentials here

2) Set your AWS localization options in the `knife.rb` file.  Specifically, you must enter a valid `key_name` in the `:bootstrap_options` section.  You should not need to change any other fields unless you wish to try this in another AWS region.

3) Ensure the private key associated with the ssh key you just specified is located in your `~/.ssh` directory.  For example, if using the default value in this repo's `knife.rb` you would need the correspoding private key in `~/.ssh/aws-id_rsa`.

4) Run `berks vendor cookbooks`

5) Run `chef-client -z -r 'recipe[chef_classroom]'` (or see the demo steps below)

You should now have a classroom set up.

To find the portal node, at this time the best way is to run the command `grep public_ipv4 nodes/mytraining-portal.json`.  There's a gem conflict preventing knife from working in local-mode that should be resolved the next time ChefDK ships.

Visit the portal node in a web browser.  Additional actions may be taken from the portal.


## Classroom workflow demonstration

To achieve the desired instructor experience, follow these steps to see a demo classroom workflow.

1) Create the student remote virtual workstations

* `chef-client -z -r 'recipe[chef_classroom::deploy_workstations]'`
* Check the portal page

2) At some appropriate point, remote virtual workstations are abandoned

* `chef-client -z -r 'recipe[chef_classroom::destroy_workstations]'`
* Check the portal page

3) At some appropriate point, students will need a target node (without chef installed) to configure

* `chef-client -z -r 'recipe[chef_classroom::deploy_first_nodes]'`
* Check the portal page

4) At some appropriate point, students need a Chef Server

* TO-DO item

5) At some appropriate point, students will need multiple target nodes (without chef installed) to configure

* `chef-client -z -r 'recipe[chef_classroom::deploy_multi_nodes]'`
* Check the portal page

6) Class ends and all nodes must be destroyed

* ``chef-client -z -r 'recipe[chef_classroom::destroy_all]'`
* Check that all nodes are terminated via AWS console

## Roadmap

The idea is to solidify this cookbook to manage all the steps required for a Chef classroom workflow.  The node managing a classroom should also eventually have an IAM role so we get out of the business of managing credentials.

The setup steps above are minimal and we should be able to put some polish around them in order to make them consumable in a more "easy to use" manner.

### TO-DO Items

* This cookbook currently relies on the `chef_workstation` cookbook to build workstations.  We should be using baked AMIs that pop out of a delivery pipeline instead of building these workstations every time.
* We should be launching a Chef Server via the AWS Marketplace AMI
* Right now the portal only displays instance IDs as a POC for how the portal works.  We need to muck with the `aws_object` method to pull out IPs for machines that haven't ever run chef-client and stuff those somewhere useful.  The approach will be some sort of method similar to this:

```
machine_image 'my_image' do
      ...
end

ruby_block "look up machine_image object" do
  block do
    aws_object = Chef::Resource::AwsImage.get_aws_object(
      'my_image',
      run_context: run_context,
      driver: run_context.chef_provisioning.current_driver,
      managed_entry_store: Chef::Provisioning.chef_managed_entry_store(run_context.cheffish.current_chef_server)
    )
  end
end
```

* We need to refactor the guacamole cookbook to allow easy workstation access.  We should then pull a recipe for that setup onto the portal node.
* We need to change up search to display the rest of the nodes we create
* Someone with front-end webdev skills should make a decent looking portal page

## Development
Usage note: if you make changes to the `chef_classroom` cookbook, you must `berks vendor cookbooks` again before running `chef-client -z` for those changes to get picked up while testing.