#!/bin/bash
#
# requires:
#  bash
#

## include files

. ${BASH_SOURCE[0]%/*}/helper_shunit2.sh
. ${BASH_SOURCE[0]%/*}/helper_failover.sh

## variables
master=${BACKUP_HOST}
backup=${MASTER_HOST}
pifname=${PUBLIC_INTERFACE}
wifname=${WAKAME_INTERFACE}

## function

function oneTimeTearDown() {
  show_physical_ipaddr ${master} ${pifname} || {
    up_interface ${master} ifname=${pifname}
    wait_sec 60
  }
}

function test_before_check() {
  before_check_master_process
  before_check_backup_process
  before_check_master_interface
  before_check_backup_interface
  before_check_master_repl
  before_check_backup_repl
  check_executed_gtid_set
}

function test_failover_stop_interface() {
  down_interface ${master} ifname=${pifname}
  assertEquals 0 $?

  wait_sec 180
  echo "failover finished"
}

function test_after_check() {
  after_check_backup_process
  after_check_master_process
  after_check_backup_interface
  after_check_master_interface
  after_check_master_repl
}

## shunit2

. ${shunit2_file}
