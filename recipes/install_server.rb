#
# Cookbook Name:: rightscale_jenkins
# Recipe:: install_server
#
# Copyright (C) 2013 RightScale, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

marker "recipe_start_rightscale" do
  template "rightscale_audit_entry.erb"
end

# Create the home directory for Jenkins.
directory node[:rightscale_jenkins][:server][:home] do
  mode 0755
  recursive true
  owner node[:rightscale_jenkins][:server][:system_user]
  group node[:rightscale_jenkins][:server][:system_group]
end

# Create Jenkins private key file
file node[:rightscale_jenkins][:private_key_file] do
  content node[:rightscale_jenkins][:private_key]
  mode 0600
  owner node[:rightscale_jenkins][:server][:system_user]
  group node[:rightscale_jenkins][:server][:system_group]
  action :create
end

# Jenkins package installation based on platform
case node[:platform]
when "centos"
  # Add Jenkins repo
  remote_file "/etc/yum.repos.d/jenkins.repo" do
    source "http://pkg.jenkins-ci.org/redhat/jenkins.repo"
  end

  # Import Jenkins RPM key
  execute "import jenkins key" do
    command "rpm --import http://pkg.jenkins-ci.org/redhat/jenkins-ci.org.key"
  end

  # If a version is specified, include the release information. This is only
  # required for CentOS. The release appears to be the same for all Jenkins
  # versions available.
  node[:rightscale_jenkins][:server][:version] += "-1.1" \
    if node[:rightscale_jenkins][:server][:version]
  # Install Jenkins package
  package "jenkins" do
    version node[:rightscale_jenkins][:server][:version]
  end

when "ubuntu"
  # Download the deb package file for the specified version
  remote_file "/tmp/jenkins_#{node[:rightscale_jenkins][:server][:version]}_all.deb" do
    source "http://pkg.jenkins-ci.org/debian/binary/" +
      "jenkins_#{node[:rightscale_jenkins][:server][:version]}_all.deb"
  end

  # dpkg doesn't resolve and install all dependencies and some of the packages
  # that jenkins depends are virtual packages provided by some other packages.
  # So Install all the dependencies before attempting to install jenkins deb
  # package. This complex setup is only required to install a specific version
  # of jenkins as the latest version might break the existing monkey
  # configuration.
  jenkins_dependencies = [
    "daemon",
    "adduser",
    "psmisc"
  ]

  jenkins_dependencies.each do |pkg|
    package pkg
  end

  # Install Jenkins from the downloaded deb file
  dpkg_package "jenkins" do
    source "/tmp/jenkins_#{node[:rightscale_jenkins][:server][:version]}_all.deb"
    action :install
  end

end

service "jenkins" do
  action :stop
end

# Change the jenkins user to root. Virtualmonkey doesn't allow running jenkins
# jobs as jenkins user or any other regular user. So jenkins should run as
# root. The following ticket is filed with virtualmonkey
# https://wush.net/trac/rightscale/ticket/5651
# Once this ticket is fixed, a new 'monkey' group can be created and any user
# belonging to that group will be allowed to run monkey tests.
#
template node[:rightscale_jenkins][:system_config_file] do
  source "jenkins_system_config.erb"
  owner node[:rightscale_jenkins][:server][:system_user]
  group node[:rightscale_jenkins][:server][:system_group]
  mode 0644
  variables(
    :jenkins_home => node[:rightscale_jenkins][:server][:home],
    :jenkins_user => node[:rightscale_jenkins][:server][:system_user],
    :jenkins_port => node[:rightscale_jenkins][:server][:port]
  )
end

# Make sure the permission for jenkins log directory set correctly
directory "/var/log/jenkins" do
  mode 0750
  owner node[:rightscale_jenkins][:server][:system_user]
  group node[:rightscale_jenkins][:server][:system_group]
end

# Create the Jenkins user directory
directory "#{node[:rightscale_jenkins][:server][:home]}/users/" +
  "#{node[:rightscale_jenkins][:server][:user_name]}" do
  recursive true
  mode 0755
  owner node[:rightscale_jenkins][:server][:system_user]
  group node[:rightscale_jenkins][:server][:system_group]
end

# Create the Jenkins configuration file to include matrix based security
template "#{node[:rightscale_jenkins][:server][:home]}/config.xml" do
  source "jenkins_config.xml.erb"
  mode 0644
  owner node[:rightscale_jenkins][:server][:system_user]
  group node[:rightscale_jenkins][:server][:system_group]
  variables(
    :user => node[:rightscale_jenkins][:server][:user_name]
  )
end


# Obtain the hash of the password.
chef_gem "bcrypt-ruby"

require "bcrypt"
node[:rightscale_jenkins][:server][:password_encrypted] = ::BCrypt::Password.create(
  node[:rightscale_jenkins][:server][:password]
)

# Create Jenkins user configuration file.
template "#{node[:rightscale_jenkins][:server][:home]}/users/" +
  "#{node[:rightscale_jenkins][:server][:user_name]}/config.xml" do
  source "jenkins_user_config.xml.erb"
  mode 0644
  owner node[:rightscale_jenkins][:server][:system_user]
  group node[:rightscale_jenkins][:server][:system_group]
  variables(
    :user_full_name => node[:rightscale_jenkins][:server][:user_full_name],
    :password_encrypted => node[:rightscale_jenkins][:server][:password_encrypted],
    :email => node[:rightscale_jenkins][:server][:user_email]
  )
end

service "jenkins" do
  action :start
end

# Open Jenkins server port
sys_firewall "8080"

right_link_tag "jenkins:active=true"
right_link_tag "jenkins:master=true"
right_link_tag "jenkins:listen_ip=#{node[:rightscale_jenkins][:ip]}"
right_link_tag "jenkins:listen_port=#{node[:rightscale_jenkins][:server][:port]}"
