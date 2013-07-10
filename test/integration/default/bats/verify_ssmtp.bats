#!/usr/bin/env bats

find_mailtrap_bin() {
  export MAILTRAP_BIN=$(find $GEM_PATH -name 'mailtrap' -type f -executable | sort | head -n1)
}

wait_for_mailtrap_ready() {
  # Install netstat first if not found
  if [ ! -x "$(which netstat)" ]; then
    if [ -x "$(which yum)" ]; then
      yum install -y net-tools
    elif [ -x "$(which apt-get)" ]; then
      apt-get install -y net-tools
    fi
  fi

  # Check whether sendmail is running with netstat, wait max 5 seconds for it to be ready
  # Prevents test fails due to race condition
  local max_wait=0;
  while ! netstat -tln | grep -q ':2525'; do sleep 1; let max_wait++; [ $max_wait -gt 5 ] && break; done
}

setup() {
  ## Debugging
  # export PS4='(${BASH_SOURCE}:${LINENO}): - [${SHLVL},${BASH_SUBSHELL},$?] $ '
  # set -x
  vagrant_groups=$(groups | sed -e 's/[[:space:]]*vagrant[[:space:]]*//' -e 's/$/ mail/' -e 's/^[[:space:]]*//'  -e 's/[[:space:]]/,/g')
  sudo usermod -G $vagrant_groups vagrant
  export GEM_BIN='/opt/chef/embedded/bin/gem'
  export GEM_OPTS='--no-rdoc --no-ri'
  export RUBY_BIN='/opt/chef/embedded/bin/ruby'
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
    $GEM_BIN install mailtrap  --version ">= ${MAILTRAP_VERSION}" ${GEM_OPTS} | ( wget $MAILTRAP_URI -O /tmp/${MAILTRAP_GEM_PACKAGE} && $GEM_BIN install /tmp/${MAILTRAP_GEM_PACKAGE} ${GEM_OPTS} )
    find_mailtrap_bin
    [ ! -x "$MAILTRAP_BIN" ] && echo "ERROR: Could not install mailtrap for sendmail testing..." && exit 1
    $RUBY_BIN $MAILTRAP_BIN start || echo 'ERROR: Could not start mailtrap for sendmail testing...'
  fi
  wait_for_mailtrap_ready
}

teardown() {
  if [ -n "$MAILTRAP_BIN" ]; then
    $RUBY_BIN $MAILTRAP_BIN stop 1>/dev/null
  fi
}

test_ssmtp_as_root() {
  echo test | /sbin/ssmtp -v -s 'testing ssmtp as root' $TEST_EMAIL_ADDRESS
}

test_ssmtp_as_vagrant() {
  su - vagrant -c "echo test | /sbin/ssmtp -v -s 'testing ssmtp as vagrant' $TEST_EMAIL_ADDRESS"
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

