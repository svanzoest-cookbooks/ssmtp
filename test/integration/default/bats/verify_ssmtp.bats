#!/usr/bin/env bats

find_mailtrap_bin() {
  export MAILTRAP_BIN=$(find $GEM_PATH -name 'mailtrap' -type f -perm /111 | sort | head -n1)
}

wait_for_mailtrap_ready() {

  ## Debugging
  # ps aux | grep mailtrap && echo 'mailtrap RUNNING' || echo 'mailtrap not running'
  # $RUBY_BIN $MAILTRAP_BIN status

  # Check whether sendmail is running with netstat, wait max tries for it to be ready
  # Prevents test fails due to race condition
  local counter=0;
  local result=1;
  while [ $result -ne 0 ]; do
    echo -e 'HELO\r\nQUIT' | telnet localhost 2525 2>/dev/null | grep -q '^220'
    result=$?
    sleep 2; # Even with sleep 1 & the telnet check we still end up with a race condition?!
    counter=$((counter+1));
    [ $counter -gt 5 ] && break;
  done
}

setup() {
  ## Debugging
  # export PS4='(${BASH_SOURCE}:${LINENO}): - [${SHLVL},${BASH_SUBSHELL},$?] $ '
  # set -x
  set +e
  set +T
  set +E

  # Install telnet, wget first if not found
  test_deps='telnet wget'
  for dep in $test_deps; do
    if [ -x "$(which yum)" ]; then
      [ ! -x "$(which $dep)" ] && yum install -y $dep
    elif [ -x "$(which apt-get)" ]; then
      [ ! -x "$(which $dep)" ] && apt-get install -y $dep
    fi
    [ -x $(which $dep) ] || echo "ERROR: Could not install $dep"
  done
  
  # Append mail to the list of groups the vagrant user is already in
  vagrant_groups=$(sudo su - vagrant -c "groups | sed -e 's/[[:space:]]*vagrant[[:space:]]*//' -e 's/\$/ mail/' -e 's/^[[:space:]]*//'  -e 's/[[:space:]]/,/g'")
  sudo su - -c "usermod -G $vagrant_groups vagrant" # Allow vagrant user to send mail for our tests
  export GEM_PATH='/opt/chef/embedded/lib/ruby/gems/1.9.1'
  export GEM_BIN='/opt/chef/embedded/bin/gem'
  export GEM_OPTS='--no-rdoc --no-ri'
  export RUBY_BIN='/opt/chef/embedded/bin/ruby'
  export SSMTP_BIN="$(sudo su - -c 'which ssmtp')" # On CentOS-59, sbin is only in root's PATH
  export TEST_EMAIL_ADDRESS='user@example.com'
  export MAILTRAP_VERSION='0.2.3'
  export MAILTRAP_PRE_RELEASE_VERSION='0.2.3.20130709144258'
  export MAILTRAP_GEM_PACKAGE="mailtrap-${MAILTRAP_PRE_RELEASE_VERSION}.gem"
  export MAILTRAP_URI="http://www.lyraphase.com/src/pub/gems/${MAILTRAP_GEM_PACKAGE}"
  
  find_mailtrap_bin
  if [ -n "$MAILTRAP_BIN" ]; then
    $RUBY_BIN $MAILTRAP_BIN status | grep -q 'mailtrap: running' || $RUBY_BIN $MAILTRAP_BIN start
  else
    # get mailtrap-0.2.3.gem from pre-release source until official 0.2.3 is available via rubygems
    sudo $GEM_BIN install mailtrap  --version ">= ${MAILTRAP_VERSION}" ${GEM_OPTS} | ( wget $MAILTRAP_URI -O /tmp/${MAILTRAP_GEM_PACKAGE} && sync && sleep 1 && sudo $GEM_BIN install /tmp/${MAILTRAP_GEM_PACKAGE} ${GEM_OPTS} )
    sync
    sleep 1
    find_mailtrap_bin
    [ ! -x "$MAILTRAP_BIN" ] && echo "ERROR: Could not install mailtrap for sendmail testing..." && exit 1
    $RUBY_BIN $MAILTRAP_BIN start || echo 'ERROR: Could not start mailtrap for sendmail testing...'
  fi
  wait_for_mailtrap_ready
  ## Debugging
  # $RUBY_BIN $MAILTRAP_BIN status
  # whoami
  set -e
  set -E
  set -T
}

teardown() {
   if [ -n "$MAILTRAP_BIN" ]; then
     $RUBY_BIN $MAILTRAP_BIN stop 1>/dev/null
   fi
    # set +x
}

test_ssmtp_as_root() {
  sudo su - -c "echo -e 'Subject: testing ssmtp as root\ntest\n.' | $SSMTP_BIN -v $TEST_EMAIL_ADDRESS"
  grep -qr 'testing ssmtp as root' /var/tmp/mailtrap/*
}

test_ssmtp_as_vagrant() {
  sudo su - vagrant -c "echo -e 'Subject: testing ssmtp as vagrant\ntest\n.' | $SSMTP_BIN -v $TEST_EMAIL_ADDRESS"
  grep -qr 'testing ssmtp as vagrant' /var/tmp/mailtrap/*
}

@test "verify ssmtp binary was installed" {
  [ -x "$SSMTP_BIN" ] || (echo "ERROR: Looks like the ssmtp binary ($SSMTP_BIN) was not installed or not executable..." && echo 'exit 1')
}

@test "verify sending mail as root" {
  run test_ssmtp_as_root
  [ "$status" -eq 0 ]
}

@test "verify sending mail as user in mail group" {
  run test_ssmtp_as_vagrant
  [ "$status" -eq 0 ]
}
#Newline is important here... otherwise bats dies with syntax errror
# See: https://github.com/sstephenson/bats/issues/12

