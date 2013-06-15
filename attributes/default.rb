#
# Cookbook Name:: ssmtp
# Attributes:: ssmtp
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

default['ssmtp']['mailhub_name'] = 'localhost'
default['ssmtp']['mailhub_port'] = 587
default['ssmtp']['hostname'] = node['hostname']
default['ssmtp']['rewrite_domain'] = node['domain']

default['ssmtp']['from_line_override'] = true

default['ssmtp']['credential_method'] = 'data_bag'         # or plain

default['ssmtp']['root'] = false
default['ssmtp']['auth_method'] = false
default['ssmtp']['auth_username'] = false
default['ssmtp']['auth_password'] = false
default['ssmtp']['use_starttls'] = true
default['ssmtp']['use_tls'] = true
