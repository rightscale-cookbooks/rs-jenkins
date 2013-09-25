#
# Cookbook Name:: rs-jenkins
# Recipe:: do_attach_request
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

require "jenkins_api_client"

# Add the jenkins public key to allow master to connect to the slave
execute "add jenkins public key to authorized keys" do
  command "echo \"#{node[:'rs-jenkins'][:public_key]}\"" +
    " >> #{ENV['HOME']}/.ssh/authorized_keys"
  not_if do
    File.open("#{ENV['HOME']}/.ssh/authorized_keys").lines.any? do |line|
      line.chomp == node[:'rs-jenkins'][:public_key]
    end
  end
end

# Obtain information about Jenkins master by querying for its tags
r = rightscale_server_collection "master_server" do
  tags "jenkins:master=true"
  mandatory_tags "jenkins:active=true"
  action :nothing
end
r.run_action(:load)

master_ip = ""
master_port = ""

r = ruby_block "find master" do
  block do
    node[:server_collection]["master_server"].each do |id, tags|
      master_ip_tag = tags.detect { |u| u =~ /jenkins:listen_ip/ }
      master_port_tag = tags.detect { |u| u =~ /jenkins:listen_port/ }
      master_ip = master_ip_tag.split(/=/, 2).last.chomp
      master_port = master_port_tag.split(/=/, 2).last.chomp

      Chef::Log.info "Master IP: #{master_ip}"
      Chef::Log.info "Master Port: #{master_port}"
    end
  end
end

r.run_action(:create)

# Attach the slave to the master using the API
ruby_block "Attach slave using Jenkins API" do
  block do
    if node[:'rs-jenkins'][:slave][:attach_status] == :attached
      log "  Already attached to Jenkins master."
    else
      client = JenkinsApi::Client.new(
        :server_ip => master_ip,
        :server_port => master_port,
        :username => node[:'rs-jenkins'][:server][:user_name],
        :password => node[:'rs-jenkins'][:server][:password]
      )

      client.node.create_dump_slave(
        :name => node[:'rs-jenkins'][:slave][:name],
        :slave_user => node[:'rs-jenkins'][:slave][:user],
        :slave_host => node[:'rs-jenkins'][:ip],
        :private_key_file => node[:'rs-jenkins'][:private_key_file],
        :mode => node[:'rs-jenkins'][:slave][:mode],
        :executors => node[:'rs-jenkins'][:slave][:executors]
      )
      node[:'rs-jenkins'][:slave][:attach_status] = :attached
    end
  end
end

# Add slave tags with the information unique to the slave
right_link_tag "jenkins:slave=true"
right_link_tag "jenkins:slave_name=#{node[:'rs-jenkins'][:slave][:name]}"
right_link_tag "jenkins:slave_mode=#{node[:'rs-jenkins'][:slave][:mode]}"
right_link_tag "jenkins:slave_ip=#{node[:'rs-jenkins'][:ip]}"
