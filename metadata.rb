name             "ssmtp"
maintainer       "Sander van Zoest"
maintainer_email "sander@vanzoest.com"
license          "Apache 2.0"
description      "Installs/Configures ssmtp"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "0.3.1"

%w{ debian ubuntu centos scientific }.each do |os|
    supports os
end

depends 'yum'
