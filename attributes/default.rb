#
# Cookbook Name:: rightscale_jenkins
# Attribute:: default
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

# Attributes for Jenkins master

# To support running the use of this cookbook inside a Vagrant box
if node[:cloud]
  default[:rightscale_jenkins][:ip] = node[:cloud][:public_ips][0]
else
  default[:rightscale_jenkins][:ip] = "127.0.0.1"
end
# Jenkins server home
default[:rightscale_jenkins][:server][:home] = "/var/lib/jenkins"
# Jenkins system user
default[:rightscale_jenkins][:server][:system_user] = "root"
# Jenkins system group
default[:rightscale_jenkins][:server][:system_group] = "root"
# Jenkins server port
default[:rightscale_jenkins][:server][:port] = "8080"
# Jenkins mirror
default[:rightscale_jenkins][:mirror] = "http://updates.jenkins-ci.org"
# The version used for jenkins_api_client gem
default[:rightscale_jenkins][:server][:jenkins_api_client_version] = "0.9.1"
# Attributes for Jenkins slave

# Jenkins slave user
default[:rightscale_jenkins][:slave][:user] = "root"
# Jenkins slave name
default[:rightscale_jenkins][:slave][:name] = node[:rightscale][:instance_uuid]
# Jenkins slave mode
default[:rightscale_jenkins][:slave][:mode] = "normal"
# Number of executors for jenkins slave
default[:rightscale_jenkins][:slave][:executors] = "10"
#
default[:rightscale_jenkins][:private_key_file] = "#{node[:rightscale_jenkins][:server][:home]}/" +
  "jenkins_key"
default[:rightscale_jenkins][:slave][:attach_status] = "unattached"

# Required attributes
#

# Jenkins user name
default[:rightscale_jenkins][:server][:user_name] = ""
# Jenkins user email
default[:rightscale_jenkins][:server][:user_email] = ""
# Jenkins user full name
default[:rightscale_jenkins][:server][:user_full_name] = ""
# Jenkins password
default[:rightscale_jenkins][:server][:password] = ""

# Optional attributes
#

# Jenkins version to install
default[:rightscale_jenkins][:server][:version] = ""
# Jenkins plugins to install
default[:rightscale_jenkins][:server][:plugins] = ""
