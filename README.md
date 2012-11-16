# ssmtp-cookbook

## Synopsis

This is a [Chef](http://www.opscode.com/chef) cookbook for deploying [ssmtp](http://linux.die.net/man/8/ssmtp). So far it is tested on Debian (6+) only.

## Requirements

### Miscellaneous

* [Chef Solo](http://wiki.opscode.com/display/chef/Chef+Solo) or [Chef Server](http://wiki.opscode.com/display/chef/Chef+Server) environment

### Chef dependencies

* No dependencies yet

## Usage

### Adding the cookbook

Add it to your Librarian-chef `Cheffile`:

    cookbook 'ssmtp',
      :git => 'https://github.com/fooforge/ssmtp-cookbook.git'

Or clone the cookbook into your local chef repository:

    git clone https://github.com/fooforge/ssmtp-cookbook.git

### Configuration

The cookbook provides a couple attributes that help you to configure ssmtp via a role's `default_attributes`.

Here's an example role:

	name 'mail_server'
	description "Installs mail related applications."
	# List of recipes and roles to apply. Requires Chef 0.8, earlier versions use 'recipes()'.
	run_list(
	  'recipe[ssmtp]'
	)
	# Attributes applied if the node doesn't have it set already.
	default_attributes(
	  'ssmtp' => {
	    'root' => 'user@example.com',
	    'rewrite_domain' => 'example.com',
	    'mailhub_name' => 'smtp.example.com'
	  }
	)
	# Attributes applied no matter what the node has set already.
	#override_attributes(
	#)

For a full list of attributes please consult `./attributes/default.rb`.

#### Authentication
	
The cookbook provides an attribute called `credential_method` which defines whether authentication credentials are provided in a crypted data bag or via plain text. It defaults to the more secure crypto data bag method.

Available options are:

* data_bag
* plain

##### Creating the data bag

	|ruby-1.9.3-p194@hosted-chef| nb-madolphs in ~/Development/Personal/Repositories/hosted-chef
	± |master ✓| → knife data bag create --secret-file .chef/encrypted_data_bag_secret mail ssmtp
	Created data_bag[mail]
	Created data_bag_item[ssmtp]		
	
	|ruby-1.9.3-p194@hosted-chef| nb-madolphs in ~/Development/Personal/Repositories/hosted-chef
	± |master ✓| → mkdir -p data_bags/mail
	
	|ruby-1.9.3-p194@hosted-chef| nb-madolphs in ~/Development/Personal/Repositories/hosted-chef
	± |master ✓| → knife data bag show mail ssmtp -F json > data_bags/mail/ssmtp.json

##### Viewing the data bag

	± |master ✗| → knife data bag show --secret-file .chef/encrypted_data_bag_secret mail ssmtp
	id:        ssmtp
	password:  foobar
	username:  user@example.com
	
	± |master ✗| → knife data bag show --secret-file .chef/encrypted_data_bag_secret -F json mail ssmtp
	{
	  "username": "user@example.com",
	  "id": "ssmtp",
	  "password": "foobar"
	}

## Development

* Source hosted at [GitHub](https://github.com/fooforge/ssmtp-cookbook)
* Report issues/Questions/Feature requests on [GitHub](https://github.com/fooforge/ssmtp-cookbook/issues) as well

Pull requests are very welcome! Make sure your patches are well tested.

## License

Copyright © 2009, Sander van Zoest  
Copyright © 2012, Mike Adolphs

Licensed under the Apache License, Version 2.0 (the "License");  
you may not use this file except in compliance with the License.  
You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software  
distributed under the License is distributed on an "AS IS" BASIS,  
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.  
See the License for the specific language governing permissions and  
limitations under the License.