# Chef_Classroom Cookbook

This cookbook manages the deployment logic for managing instances used in Chef training during the lifecycle of classes in Chef's training catalog.

## Pre-Requisites
In order to use this repo, you must have the following setup:

#### Chef Requirements
* Install ChefDK 0.9.0
* Update chef-provisioning to 1.2.1
* Update chef-provisioning-aws to 1.5.1

#### AWS Requirements
* [AWS API credentials][APIcreds] to start a classroom portal EC2 instance
* [AWS IAM Instance Profile][InstanceProfile] with associated policy allowing `AmazonEC2FullAccess` (assigned to the portal instance)
* [AWS Marketplace][Marketplace] accept the EULA for base CentOS, Windows, and Chef Server AMIs
  * [Centos 6 (x86_64) - with updates HVM][Centos6]
  * [Microsoft Windows Server 2012 R2 Core][Windows2012]
  * [Chef Server Free][ChefServer]

Details on fulfilling AWS Requirements below

## Usage
To set up a Chef Training Classroom, do the following:

1. Create your `~/.aws/config` file if you don't already have one.  It should have content similar to the snippet below, except with your own AWS API credentials here:

    ```
    [default]
    aws_access_key_id = AKIAAABBCCDDEEFFGGHH
    aws_secret_access_key = "Abc0123dEf4GhIjk5lMn/OpQrSTUvXyz/A678bCD"
    ```
2. Set the ARN name of your IAM Instance Profile in `attributes/default.rb` as the value of `chef_classroom['iam_instance_profile']`.

3. Additional options may be set, including automatic localization via the `chef_classroom['region']` attribute (note: so far only AWS US regions available).  Instructors are ***strongly encouraged*** to replace the value of `chef_classroom['ip_range']` with an appropriate IP address range (e.g. "184.106.28.82/32") for any classroom being managed.  The permissions and security settings of these instances are... lax.  However, none of these changes are required for basic (demo) use of this repo.

5. Run `berks vendor cookbooks`

6. Run `chef-client -z -r 'recipe[chef_classroom::deploy_portal]'`

7. You should now have a Classroom Portal set up.  Visit the portal web UI in a browser by hitting the front-end IP.  To find the portal node front-end IP, at this time the best way is to run the command `grep public_ipv4 nodes/mytraining-portal.json`.  There's a gem conflict preventing knife from working in local-mode that should be resolved the next time ChefDK ships.

Visit the portal node in a web browser.  Additional actions [should be taken][WebUIactions] from the portal to run your class.  These actions are not yet available.  See the Demo workflow below and follow steps 1-3 to get an entire classroom provisioned for training material verification.

*Setup steps 1-6 (above) could be handled by shipping a pre-baked Chef Classroom AMI.  See the Roadmap section below for intended usage and next steps.*

## Classroom Workflow Demo
Only Chef Fundamentals 3.x workflow is currently supported.

Additional actions [from the web UI][WebUIactions] are not yet available.  So to see the instructor experience, you have to run chef-provisioning recipes via the local shell.  The mock buttons in the web UI should eventually do this.  But for now, your steps to see the classroom go are:

1. SSH to the portal instance and cd into the chef_classroom dir (See [AWS Setup](#aws-setup) for details).

    ```
    ssh root@PORTAL_ADDRESS -i ~/.ssh/CLASSNAME-workstation_key
    [root@PORTAL_ADDRESS]# cd chef_classroom
    ```

2. Presently, you have to set your classroom attributes once again on the portal instance.  **Ensure you set the same ARN name as you used to provision the portal instance.  Again, set all of your desired classroom settings here.**
Every time you make a local modification to the code in the `chef_classroom` cookbook dir, you must re-vendor cookbooks.  (TODO: fix this duplicate step)

     ```
     [root@PORTAL_ADDRESS chef_classroom]# vi attributes/default.rb
     [root@PORTAL_ADDRESS chef_classroom]# rm -rf cookbooks
     [root@PORTAL_ADDRESS chef_classroom]# berks vendor cookbooks
     ```
3. To create the entire classroom in one fell swoop, run the default recipe.

   * `chef-client -z -r 'recipe[chef_classroom]'`
   * The classroom environment takes about 30-40 mins to build
   * Check the portal webpage

Alternately, you may instead manage the classroom in steps that match our proposed instructor workflow.

1. Create the student remote virtual workstations

   * `chef-client -z -r 'recipe[chef_classroom::deploy_workstations]'`
   * Check the portal page

2. **Optional**: At some appropriate point, remote virtual workstations are abandoned

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

When you are finished with the classroom environment, all nodes must be destroyed (including the portal).

1. Class ends and all workstations, nodes, and the Chef server must be destroyed

   * From the portal instance, `chef-client -z -r 'recipe[chef_classroom::destroy_lab]'`
   * Check that all nodes are terminated via AWS console

2. Destroy the portal instance from your local workstation

   * From your workstation, `chef-client -z -r 'recipe[chef_classroom::destroy_portal]'`
   * Or if we ship an AMI, this can be done via typical EC2 management methods

## Known issues

  * Depending on your workflow, sometimes the portal page may not properly refresh.  You can force a refresh of the portal page with `chef-client -z -r 'recipe[chef_classroom::_refresh_portal]`

  * On occasion, chef-provisioning-aws may lose track of an object it provisioned and you will get errors similar to

    ```
    Problem: AWS::EC2::Errors::InvalidInstanceID::NotFound

    The instance ID 'i-a1b2c3d4' does not exist
    ```

    This transient error has been [difficult to replicate][InvalidID], but should hopefully be fixed in chef-provisioning-aws v.1.4.0.  If this error occurs, run the chef recipe again and it will pick up where you left off.  You will have an unmanaged instance occupying your security group when you attempt to destroy the entire classroom.  So you will see an error specifying your SG's cannot be removed.  You may manually remove the transient instance(s) and try again.  Another option may be to set `action :purge` on the aws_security_group resources that clean everything up.

  * AWS API Rate Limits are in place to throttle instance creation requests as a DDOS prevention technique.  You may see these errors if creating large batches of machines all at once.

    ```
    AWS::EC2::Errors::RequestLimitExceeded: Request limit exceeded
    ```

    These limits may be adjusted for your AWS account by contacting support.  If you see errors indicating you've hit these limits, the best thing to do is get them raised.  Alternately, you may just run the recipe again and it will pick up where it left off.

Other normal EC2 error conditions apply (e.g. account quotas, IAM permissions, etc)

# AWS Setup

## Instance Access
If you started this environment from a workstation using chef-provisioning, you now have a new ssh key called "#{name}-workstation_key", where `name` is the name of the classroom you set.  If you used defaults, it is located in `~/.ssh/mytraining-workstation_key`.  To reach your workstation, run the following command from a terminal.

  ```
  ssh -i ~/.ssh/CLASSNAME-workstation_key -l root <ip of your instance>

  ```
By default, the [chef_portal][portal] cookbook sets up password auth on the portal instance.  Alternatively, you may SSH in to the portal instance as the portal user using the portal password from that cookbook.

## Marketplace
For AMI consistency, this repo uses AWS Marketplace images for Centos6, Windows 2012, and Chef Server.  **You must accept the licensing terms** from your AWS account for each of those AMIs, in each region for which you want to deploy a classroom, before this repo will work.  If you have not, chef-provisioning-aws will throw an error letting you know you must go do this.

The Marketplace AMIs used are referenceable at:

* [Centos 6 AMI][Centos6]
* [Windows 2012][Windows2012]
* [Chef Server 12][ChefServer]

## API Credentials
Follow [these instructions][APIcredsCreate] to create API credentials.

## IAM Instance Profile
Follow [these instructions][IAMroleconsole] to create IAM roles via the AWS console.  When you create this role, select `AmazonEC2FullAccess` as the 'policy to attach'.  Once you create the role, note the 'Instance Profile ARN(s)'.  Use this value as the ARN in your attributes file.

# Roadmap
The idea is to solidify this cookbook to manage all the steps required for a Chef classroom workflow.  This cookbook should only handle chef-provisioning logic.

There are (currently), two dependent cookbooks that probably should be packaged as AMIs.  The chef server is also a time consuming piece to build and may be a candidate to package as well.

* [chef_workstation][workstation] -- sets us student workstations for Fundamentals 3.x
* [chef_portal][portal] -- sets up the classroom portal instance

At present the Chef Server setup takes ~15 mins and consumes a large majority of the classroom setup time (~30 mins).  The initial compile of guacamole on the portal instance is also significant (~10 mins).  The goal probably would be to stop building these on the fly and use pre-baked images instead (using the chef recipes demonstrated here) once this passes the MVP phase.

The setup steps above are minimal and we should be able to put some polish around them in order to make them consumable in a more "easy to use" manner.

See [issues](https://github.com/chef-training/chef_classroom/issues) for other pending items.


## Development
Usage note: if you make changes to the `chef_classroom` cookbook, you must `berks vendor cookbooks` again before running `chef-client -z` for those changes to get picked up while testing.

[APIcreds]:        http://docs.aws.amazon.com/general/latest/gr/getting-aws-sec-creds.html
[APIcredsCreate]:  http://docs.aws.amazon.com/IAM/latest/UserGuide/ManagingCredentials.html#Using_CreateAccessKey
[InstanceProfile]: http://docs.aws.amazon.com/IAM/latest/UserGuide/roles-usingrole-instanceprofile.html
[IAMroles]:        http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/iam-roles-for-amazon-ec2.html#launch-instance-with-role-console
[IAMroleconsole]:  http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/iam-roles-for-amazon-ec2.html#create-iam-role-console
[Marketplace]:     https://aws.amazon.com/marketplace
[Centos6]:         https://aws.amazon.com/marketplace/pp/B00NQAYLWO/ref=srh_res_product_title?ie=UTF8&sr=0-5&qid=1438798120883
[Windows2012]:     https://aws.amazon.com/marketplace/pp/B00KQOWEPO/ref=srh_res_product_title?ie=UTF8&sr=0-2&qid=1438798402893
[ChefServer]:      https://aws.amazon.com/marketplace/pp/B010OMNV2W/ref=srh_res_product_title?ie=UTF8&sr=0-6&qid=1438798452150
[WebUIactions]:    https://github.com/chef-training/chef_classroom/issues/14
[portal]:          https://github.com/chef-training/chef_portal
[workstation]:     https://github.com/chef-training/chef_workstation
[InvalidID]:       https://github.com/chef/chef-provisioning-aws/issues/264
