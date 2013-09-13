name             'rightscale_jenkins'
maintainer       'RightScale, Inc.'
maintainer_email 'cookbooks@rightscale.com'
license          'Apache 2.0'
description      "Installs/Configures Jenkins"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "13.5.0"

supports "centos"
supports "redhat"
supports "ubuntu"

depends "rightscale"
depends "sys_firewall"

recipe "rightscale_jenkins::default",
  "Install the dependencies for jenkins."
recipe "rightscale_jenkins::install_server",
  "Install Jenkins server and configure it using the inputs provided."
recipe "rightscale_jenkins::do_attach_request",
  "Attach a slave node to the master Jenkins server."
recipe "rightscale_jenkins::do_attach_slave_at_boot",
  "Attach a slave node to the master Jenkins server at boot time if" +
  " `jenkins/attach_slave_at_boot` is set to true"

# Server/Master Attributes

attribute "rightscale_jenkins/server/user_name",
  :display_name => "rightscale_jenkins User Name",
  :description =>
    "Default user's sign in name.",
  :required => "required",
  :recipes => [
    "rightscale_jenkins::default",
    "rightscale_jenkins::install_server",
    "rightscale_jenkins::do_attach_request",
    "rightscale_jenkins::do_attach_slave_at_boot"
  ]

attribute "rightscale_jenkins/server/user_email",
  :display_name => "rightscale_jenkins User Email",
  :description =>
    "Default user's email.",
  :required => "required",
  :recipes => ["rightscale_jenkins::default", "rightscale_jenkins::install_server"]

attribute "rightscale_jenkins/server/user_full_name",
  :display_name => "rightscale_jenkins User Full Name",
  :description =>
    "Default user's full name.",
  :required => "required",
  :recipes => ["rightscale_jenkins::default", "rightscale_jenkins::install_server"]

attribute "rightscale_jenkins/server/password",
  :display_name => "rightscale_jenkins Password",
  :description =>
    "Default user's password.",
  :required => "required",
  :recipes => [
    "rightscale_jenkins::default",
    "rightscale_jenkins::install_server",
    "rightscale_jenkins::do_attach_request",
    "rightscale_jenkins::do_attach_slave_at_boot"
  ]

attribute "rightscale_jenkins/server/version",
  :display_name => "rightscale_jenkins Version",
  :description =>
    "rightscale_jenkins version to install. Leave it blank to get the latest version." +
    " Example: 1.500",
  :required => "optional",
  :recipes => ["rightscale_jenkins::default", "rightscale_jenkins::install_server"]

attribute "rightscale_jenkins/server/plugins",
  :display_name => "rightscale_jenkins Plugins",
  :description =>
    "rightscale_jenkins plugins to install.",
  :required => "optional",
  :recipes => ["rightscale_jenkins::default", "rightscale_jenkins::install_server"]

# Slave Attributes

attribute "rightscale_jenkins/slave/name",
  :display_name => "rightscale_jenkins Slave Name",
  :description =>
    "Name of Jenkins slave. This name should be unique. The RightScale" +
    " instance UUID will be used as the name if this input is left blank",
  :required => "optional",
  :recipes => ["rightscale_jenkins::do_attach_request", "rightscale_jenkins::do_attach_slave_at_boot"]

attribute "rightscale_jenkins/slave/mode",
  :display_name => "rightscale_jenkins Slave Mode",
  :description =>
    "Mode of Jenkins slave. Choose 'normal' if this slave can be used for" +
    " running any jobs or choose 'exclusive' if this slave should be used" +
    " only for tied jobs.",
  :default => "normal",
  :choice => ["normal", "exclusive"],
  :recipes => ["rightscale_jenkins::do_attach_request", "rightscale_jenkins::do_attach_slave_at_boot"]

attribute "rightscale_jenkins/slave/executors",
  :display_name => "rightscale_jenkins Slave Executors",
  :description =>
    "Number of Jenkins executors.",
  :required => "optional",
  :recipes => ["rightscale_jenkins::do_attach_request", "rightscale_jenkins::do_attach_slave_at_boot"]

# Attributes shared between master and slave

attribute "rightscale_jenkins/public_key",
  :display_name => "rightscale_jenkins Public Key",
  :description =>
    "This public key will be used by Jenkins slave to allow connections from" +
    " the master/server",
  :required => "required",
  :recipes => ["rightscale_jenkins::do_attach_request", "rightscale_jenkins::do_attach_slave_at_boot"]

attribute "rightscale_jenkins/private_key",
  :display_name => "rightscale_jenkins Private Key",
  :description =>
    "This key is used by Jenkins server/master to connect to the slave" +
    " using SSH.",
  :required => "required",
  :recipes => ["rightscale_jenkins::default", "rightscale_jenkins::install_server"]

attribute "rightscale_jenkins/attach_slave_at_boot",
  :display_name => "Attach Jenkins Slave At Boot",
  :description =>
    "Set this input to 'true' if this is a Jenkins slave and should be" +
    " connected as a slave to the Jenkins server/master at boot.",
  :default => "false",
  :choice => ["true", "false"],
  :recipes => ["rightscale_jenkins::do_attach_slave_at_boot"]
