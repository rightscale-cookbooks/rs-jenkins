#
# Cookbook Name:: rs-jenkins
# Recipe:: default
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

# The java package to install based on platform family
node[:'rs-jenkins'][:java_package] = value_for_platform_family(
  "debian" => "openjdk-6-jre",
  "default" => "java-1.6.0-openjdk"
)

# The jenkins system configuration file location based on platform family
node[:'rs-jenkins'][:system_config_file] = value_for_platform_family(
  "debian" => "/etc/default/jenkins",
  "default" => "/etc/sysconfig/jenkins"
)

# Install the java package required by Jenkins
package node[:'rs-jenkins'][:java_package]

# Install the jenkins_api_client gem
chef_gem "jenkins_api_client" do
  version node[:'rs-jenkins'][:server][:jenkins_api_client_version]
  action :install
end
