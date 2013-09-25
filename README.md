# rs-jenkins Cookbook

This cookbook is available at [https://github.com/rightscale-cookbooks/rs-jenkins](https://github.com/rightscale-cookbooks/rs-jenkins).

This cookbook provides recipes to setup and Jenkins servers and slaves.

# REQUIREMENTS:

Requires a virtual machine from a RightScale managed RightImage.
Jenkins currently runs as root user. This is required for using the
VirtualMonkey test framework. Once the test framework is fixed to run as a
regular user, this limitation can be removed.

# USAGE:

* To setup a Jenkins server include `rs-jenkins::install_server` to your runlist.
  This recipe will Jenkins server and configure the server.
* To add a server as a slave to existing Jenkins master server, run the
  `rs-jenkins::do_attach_request` recipe. This recipe will attach the server as a
  slave to the Jenkins master server found in the current deployment.

# Attributes:

These are settings used in recipes and tempaltes. Default values are noted.

Note: Only "internal" cookbook attributes are described here. Descriptions of
attributes which have inputs can be found in the metadata.rb file.

## Jenkins master attributes

* `node[:'rs-jenkins'][:ip]` - The system IP address to be used for Jenkins server.
* `node[:'rs-jenkins'][:server][:home]` - The home directory for Jenkins.
* `node[:'rs-jenkins'][:server][:system_user]` - The system user name for Jenkins.
* `node[:'rs-jenkins'][:server][:system_group]` - The system group for Jenkins.
* `node[:'rs-jenkins'][:server][:port]` - The port number for Jenkins server.
* `node[:'rs-jenkins'][:mirror]` - The mirror for downloading jenkins plugins and
  other resources.

## Jenkins slave attributes

* `node[:'rs-jenkins'][:slave][:user]` - The slave username to be used for
  connecting to the Jenkins master server.
  The RightScale Instance UUID is used if the name is not specified.
* `node[:'rs-jenkins'][:private_key_file]` - The private key file used by the master
  for SSH communications with the slave.
* `node[:'rs-jenkins'][:slave][:attach_status]` - The status of slave attachment.

# Recipes:

## `rs-jenkins::default`

This is the default recipe that sets up the platform specific attributes.

## `rs-jenkins::install_server`

This recipe installs the Jenkins server from the mirrors provided by
jenkins-ci.org. This recipe also allows a particular version of Jenkins
installed based on the `rs-jenkins/server/version` input (Please refer to the
`metadata.rb` for more information about this input).

The master node will add tags to announce itself as a master with information
about its listen IP address and Port number. Jenkins slaves will use this
information for communication.

## `rs-jenkins::do_attach_request`

This recipe attaches a server as a slave to the Jenkins master server found in
the current deployment. It uses the Jenkins API to request the master server to
attach itself as a slave. The slave nodes will add information as tags about its
IP address, mode, and name.

### Slave mode:

The mode for a slave could be either 'normal' or 'exclusive'. The slaves in
'normal' can be used to run any jobs. The slaves in 'exclusive' mode can only
run jobs that are tied/restricted to themselves. The default mode for a slave
will be 'normal' unless otherwise overridden.

### Slave name:

Jenkins master uses the name to identify slaves and restrict jobs to a
particular slave. This name will be chosen to be the RightScale Instance UUID
if it is not specified in the inputs.

# Author:

Author:: RightScale Inc. (<cookbooks@rightscale.com>)
