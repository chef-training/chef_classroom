# chef_classroom

## Pre-Requisites

In order to use this repo, you must have the following setup:

* Install ChefDK 0.6.2
* Update chef-provisioning to 1.2.1
* Update chef-provisioning-aws to 1.3.0

## Usage

To set up a Chef Training Classroom, do the following:

1. Create your `~/.aws/config` file if you don't already have one.  It should have content similar to the snippet below, except with your own AWS API credentials here:

    ```
    [default]
    aws_access_key_id = AKIAAABBCCDDEEFFGGHH
    aws_secret_access_key = "Abc0123dEf4GhIjk5lMn/OpQrSTUvXyz/A678bCD"
    ```

2. Set your AWS localization options in the `knife.rb` file.  Specifically, you must enter a valid `key_name` in the `:bootstrap_options` section.  You should not need to change any other fields unless you wish to try this in another AWS region.

3. Ensure the private key associated with the ssh key you just specified is located in your `~/.ssh` directory.  For example, if using the default value in this repo's `knife.rb` you would need the correspoding private key in `~/.ssh/aws-id_rsa`.

4. Run `berks vendor cookbooks`

5. Run `chef-client -z -r 'recipe[chef_classroom]'` (or see the demo steps below)

You should now have a classroom set up.  *Note: at present the Chef Server setup takes ~15 mins and consumes a large majority of the classroom setup time (~20 mins).*  To find the portal node, at this time the best way is to run the command `grep public_ipv4 nodes/mytraining-portal.json`.  There's a gem conflict preventing knife from working in local-mode that should be resolved the next time ChefDK ships.

Visit the portal node in a web browser.  Additional actions [should be taken](https://github.com/gmiranda23/chef_classroom/issues/14) from the portal.


## Classroom workflow demonstration

The default recipe just creates an entire classroom environment in one fell swoop.  The way ChefDK fundamentals is taught, that leaves a bunch of idle infrastructure laying around before it is ever needed.  That also doesn't match the desired instructor experience.

To achieve the desired instructor experience, follow these steps to see a demo classroom workflow.

1. Create the student remote virtual workstations

   * `chef-client -z -r 'recipe[chef_classroom::deploy_workstations]'`
   * Find the portal IP address with `grep public_ipv4 nodes/mytraining-portal.json`
   * Check the portal page

2. At some appropriate point, remote virtual workstations are abandoned

   * `chef-client -z -r 'recipe[chef_classroom::destroy_workstations]'`
   * Check the portal page

3. At some appropriate point, students will need a target node (without chef installed) to configure

   * `chef-client -z -r 'recipe[chef_classroom::deploy_first_nodes]'`
   * Check the portal page

4. At some appropriate point, students need a Chef Server

   * `chef-client -z -r 'recipe[chef_classroom::deploy_server]'`
   * Check the portal page

5. At some appropriate point, students will need multiple target nodes (without chef installed) to configure

   * `chef-client -z -r 'recipe[chef_classroom::deploy_multi_nodes]'`
   * Check the portal page

6. Class ends and all nodes must be destroyed

   * ``chef-client -z -r 'recipe[chef_classroom::destroy_all]'`
   * Check that all nodes are terminated via AWS console

## Roadmap

The idea would be to solidify this cookbook to manage all the steps required for a Chef classroom workflow.  The node managing a classroom should probably also eventually have an IAM role so we get out of the business of managing credentials.

The setup steps above are minimal and we should be able to put some polish around them in order to make them consumable in a more "easy to use" manner.

See [issues](https://github.com/gmiranda23/chef_classroom/issues) for other pending items.


## Development
Usage note: if you make changes to the `chef_classroom` cookbook, you must `berks vendor cookbooks` again before running `chef-client -z` for those changes to get picked up while testing.