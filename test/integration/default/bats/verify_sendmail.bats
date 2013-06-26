#!/usr/bin/env bats

setup() {
  vagrant_groups=$(groups | sed -e 's/[[:space:]]*vagrant[[:space:]]*//' -e 's/$/ mail/' -e 's/^[[:space:]]*//'  -e 's/[[:space:]]/,/g')
  sudo usermod -G $vagrant_groups vagrant
  export TEST_EMAIL_ADDRESS='user@example.com'
}

test_sendmail_as_root() {
  echo test | sendmail -v -s 'testing ssmtp setup' $TEST_EMAIL_ADDRESS
}

@test "verify sending mail as root" {
  run test_sendmail_as_root
  [ "$status" -eq 0 ]
}
#Newline is important here... otherwise bats dies with syntax errror
# See: https://github.com/sstephenson/bats/issues/12
