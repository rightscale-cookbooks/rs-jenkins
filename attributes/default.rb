#
# Cookbook Name:: rs-jenkins
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
  default[:'rs-jenkins'][:ip] = node[:cloud][:public_ips][0]
else
  default[:'rs-jenkins'][:ip] = "127.0.0.1"
end
# Jenkins server home
default[:'rs-jenkins'][:server][:home] = "/var/lib/jenkins"
# Jenkins system user
default[:'rs-jenkins'][:server][:system_user] = "root"
# Jenkins system group
default[:'rs-jenkins'][:server][:system_group] = "root"
# Jenkins server port
default[:'rs-jenkins'][:server][:port] = "8080"
# Jenkins mirror
default[:'rs-jenkins'][:mirror] = "http://updates.jenkins-ci.org"
# The version used for jenkins_api_client gem
default[:'rs-jenkins'][:server][:jenkins_api_client_version] = "0.9.1"
# Attributes for Jenkins slave

# Jenkins slave user
default[:'rs-jenkins'][:slave][:user] = "root"
# Jenkins slave name
default[:'rs-jenkins'][:slave][:name] = node[:rightscale][:instance_uuid]
# Jenkins slave mode
default[:'rs-jenkins'][:slave][:mode] = "normal"
# Number of executors for jenkins slave
default[:'rs-jenkins'][:slave][:executors] = "10"
#
default[:'rs-jenkins'][:private_key_file] = "#{node[:'rs-jenkins'][:server][:home]}/" +
  "jenkins_key"
default[:'rs-jenkins'][:slave][:attach_status] = "unattached"

# Required attributes
#

# Jenkins user name
default[:'rs-jenkins'][:server][:user_name] = ""
# Jenkins user email
default[:'rs-jenkins'][:server][:user_email] = ""
# Jenkins user full name
default[:'rs-jenkins'][:server][:user_full_name] = ""
# Jenkins password
default[:'rs-jenkins'][:server][:password] = ""

# Optional attributes
#

# Jenkins version to install
default[:'rs-jenkins'][:server][:version] = ""
# Jenkins plugins to install
default[:'rs-jenkins'][:server][:plugins] = ""
