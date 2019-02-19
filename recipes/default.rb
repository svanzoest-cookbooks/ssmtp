
#
# Cookbook Name:: ssmtp
# Recipe:: default
#
# Copyright 2009, Sander van Zoest
# Copyright 2012, Mike Adolphs
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

include_recipe 'yum-epel' if platform_family?('fedora', 'rhel')

package 'ssmtp' do
  action :upgrade
end

case node['ssmtp']['credential_method']
when 'data_bag'
  data_bag = data_bag_item('mail', 'ssmtp')
  username = data_bag['username']
  password = data_bag['password']
when 'plain'
  username = node['ssmtp']['auth_username']
  password = node['ssmtp']['auth_password']
end

template '/etc/ssmtp/ssmtp.conf' do
  source 'ssmtp.conf.erb'
  owner node['ssmtp']['config_owner']
  group node['ssmtp']['config_group']
  mode node['ssmtp']['config_mode']
  variables(
    'auth_username'    => username,
    'auth_password'    => password
  )
end

template '/etc/ssmtp/revaliases' do
  source 'revaliases.erb'
  owner node['ssmtp']['config_owner']
  group node['ssmtp']['config_group']
  mode node['ssmtp']['config_mode']
end
