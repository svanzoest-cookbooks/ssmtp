#!/usr/bin/env bats

find_mailtrap_bin() {
  export MAILTRAP_BIN=$(find $GEM_PATH -name 'mailtrap' -type f -executable | sort | head -n1)
}

setup() {
  ## Debugging
  # export PS4='(${BASH_SOURCE}:${LINENO}): - [${SHLVL},${BASH_SUBSHELL},$?] $ '
  # set -x
  vagrant_groups=$(groups | sed -e 's/[[:space:]]*vagrant[[:space:]]*//' -e 's/$/ mail/' -e 's/^[[:space:]]*//'  -e 's/[[:space:]]/,/g')
  sudo usermod -G $vagrant_groups vagrant
  export TEST_EMAIL_ADDRESS='user@example.com'
  
  find_mailtrap_bin
  if [ -n "$MAILTRAP_BIN" ]; then
    /opt/chef/embedded/bin/ruby $MAILTRAP_BIN start
  else
    gem install mailtrap --no-ri --no-rdoc
    find_mailtrap_bin
    [ ! -x "$MAILTRAP_BIN" ] && echo "ERROR: Could not install mailtrap for sendmail testing..." && exit 1
    /opt/chef/embedded/bin/ruby $MAILTRAP_BIN start || echo 'ERROR: Could not start mailtrap for sendmail testing...'
  fi
}

#teardown() {
#  /opt/chef/embedded/bin/ruby $MAILTRAP_BIN stop
#}

test_sendmail_as_root() {
  echo test | /usr/sbin/sendmail -v -s 'testing ssmtp setup' $TEST_EMAIL_ADDRESS
}

test_sendmail_as_vagrant() {
  su - vagrant -c "echo test | /usr/sbin/sendmail -v -s 'testing ssmtp setup' $TEST_EMAIL_ADDRESS"
}

@test "verify sending mail as root" {
  run test_sendmail_as_root
  [ "$status" -eq 0 ]
}

@test "verify sending mail as user in mail group" {
  run test_sendmail_as_vagrant
  [ "$status" -eq 0 ]
}
#Newline is important here... otherwise bats dies with syntax errror
# See: https://github.com/sstephenson/bats/issues/12

