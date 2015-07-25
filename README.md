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

5) Run `chef-client -z -r 'recipe[chef_classroom]'`

You should now have a classroom set up.

To find the portal node, at this time the best way is to run the command `grep public_ipv4 nodes/mytraining-portal.json`.  There's a gem conflict preventing knife from working in local-mode that should be resolved the next time ChefDK ships.

Visit the portal node in a web browser.  Additional actions may be taken from the portal.

