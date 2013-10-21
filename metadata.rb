name             'rs-jenkins'
maintainer       'RightScale, Inc.'
maintainer_email 'cookbooks@rightscale.com'
license          'Apache 2.0'
description      'Installs/Configures Jenkins'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '13.7.0'

supports "centos"
supports "redhat"
supports "ubuntu"

depends "rightscale"
depends "sys_firewall"
depends "marker"

recipe "rs-jenkins::default",
  "Install the dependencies for jenkins."
recipe "rs-jenkins::install_server",
  "Install Jenkins server and configure it using the inputs provided."
recipe "rs-jenkins::do_attach_request",
  "Attach a slave node to the master Jenkins server."
recipe "rs-jenkins::do_attach_slave_at_boot",
  "Attach a slave node to the master Jenkins server at boot time if" +
  " `jenkins/attach_slave_at_boot` is set to true"

# Server/Master Attributes

attribute "rs-jenkins/server/user_name",
  :display_name => "Jenkins User Name",
  :description =>
    "Default user's sign in name.",
  :required => "required",
  :recipes => [
    "rs-jenkins::default",
    "rs-jenkins::install_server",
    "rs-jenkins::do_attach_request",
    "rs-jenkins::do_attach_slave_at_boot"
  ]

attribute "rs-jenkins/server/user_email",
  :display_name => "Jenkins User Email",
  :description =>
    "Default user's email.",
  :required => "required",
  :recipes => ["rs-jenkins::default", "rs-jenkins::install_server"]

attribute "rs-jenkins/server/user_full_name",
  :display_name => "Jenkins User Full Name",
  :description =>
    "Default user's full name.",
  :required => "required",
  :recipes => ["rs-jenkins::default", "rs-jenkins::install_server"]

attribute "rs-jenkins/server/password",
  :display_name => "Jenkins Password",
  :description =>
    "Default user's password.",
  :required => "required",
  :recipes => [
    "rs-jenkins::default",
    "rs-jenkins::install_server",
    "rs-jenkins::do_attach_request",
    "rs-jenkins::do_attach_slave_at_boot"
  ]

attribute "rs-jenkins/server/version",
  :display_name => "Jenkins Version",
  :description =>
    "Jenkins version to install. Leave it blank to get the latest version." +
    " Example: 1.500",
  :required => "optional",
  :recipes => ["rs-jenkins::default", "rs-jenkins::install_server"]

attribute "rs-jenkins/server/plugins",
  :display_name => "Jenkins Plugins",
  :description =>
    "Jenkins plugins to install.",
  :required => "optional",
  :recipes => ["rs-jenkins::default", "rs-jenkins::install_server"]

# Slave Attributes

attribute "rs-jenkins/slave/name",
  :display_name => "Jenkins Slave Name",
  :description =>
    "Name of Jenkins slave. This name should be unique. The RightScale" +
    " instance UUID will be used as the name if this input is left blank",
  :required => "optional",
  :recipes => ["rs-jenkins::do_attach_request", "rs-jenkins::do_attach_slave_at_boot"]

attribute "rs-jenkins/slave/mode",
  :display_name => "Jenkins Slave Mode",
  :description =>
    "Mode of Jenkins slave. Choose 'normal' if this slave can be used for" +
    " running any jobs or choose 'exclusive' if this slave should be used" +
    " only for tied jobs.",
  :default => "normal",
  :choice => ["normal", "exclusive"],
  :recipes => ["rs-jenkins::do_attach_request", "rs-jenkins::do_attach_slave_at_boot"]

attribute "rs-jenkins/slave/executors",
  :display_name => "Jenkins Slave Executors",
  :description =>
    "Number of Jenkins executors.",
  :required => "optional",
  :recipes => ["rs-jenkins::do_attach_request", "rs-jenkins::do_attach_slave_at_boot"]

# Attributes shared between master and slave

attribute "rs-jenkins/public_key",
  :display_name => "Jenkins Public Key",
  :description =>
    "This public key will be used by Jenkins slave to allow connections from" +
    " the master/server",
  :required => "required",
  :recipes => ["rs-jenkins::do_attach_request", "rs-jenkins::do_attach_slave_at_boot"]

attribute "rs-jenkins/private_key",
  :display_name => "Jenkins Private Key",
  :description =>
    "This key is used by Jenkins server/master to connect to the slave" +
    " using SSH.",
  :required => "required",
  :recipes => ["rs-jenkins::default", "rs-jenkins::install_server"]

attribute "rs-jenkins/attach_slave_at_boot",
  :display_name => "Attach Jenkins Slave At Boot",
  :description =>
    "Set this input to 'true' if this is a Jenkins slave and should be" +
    " connected as a slave to the Jenkins server/master at boot.",
  :default => "false",
  :choice => ["true", "false"],
  :recipes => ["rs-jenkins::do_attach_slave_at_boot"]
