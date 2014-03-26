#!/bin/bash
#
# requires:
#  bash
#

## include files

## variables

## functions

### failover

function oneTimeSetUp() {
  status_keepalived ${master} | grep -w running || {
    start_keepalived ${master} 
    wait_sec 60
  }

  status_keepalived ${backup} | grep -w running || {
    start_keepalived ${backup} 
    wait_sec 60
  }
}

function before_check_master_process() {
  echo "before check master process"
  echo "check mysql-server status: running"
  status=$(status_mysqld     ${master})
  assertEquals "running..." "${status}"

  echo "check zabbix-server status: running"
  status=$(status_zabbix     ${master})
  assertEquals "running..." "${status}"

  echo "check httpd status: running"
  status=$(status_httpd      ${master})
  assertEquals "running..." "${status}"

  echo "check keepalived status: running"
  status=$(status_keepalived ${master})
  assertEquals "running..." "${status}"
}

function before_check_backup_process() {
  echo "before check backup process"
  echo "check mysql-server status: running"
  status=$(status_mysqld     ${backup})
  assertEquals "running..." "${status}"

  echo "check zabbix-server status: stopped"
  status=$(status_zabbix     ${backup})
  assertEquals "stopped"    "${status}"

  echo "check httpd status: running"
  status=$(status_httpd      ${backup})
  assertEquals "running..." "${status}"

  echo "check keepalived status: running"
  status=$(status_keepalived ${backup})
  assertEquals "running..." "${status}"
}

function after_check_master_process() {
  echo "after check master process"
  echo "check mysql-server status: running"
  status=$(status_mysqld     ${backup})
  assertEquals "running..." "${status}"

  echo "check zabbix-server status: running"
  status=$(status_zabbix     ${backup})
  assertEquals "running..." "${status}"

  echo "check httpd status: running"
  status=$(status_httpd      ${backup})
  assertEquals "running..." "${status}"

  echo "check keepalived status: running"
  status=$(status_keepalived ${backup})
  assertEquals "running..." "${status}"
}

function after_check_backup_process() {
  echo "after check backup process"
  echo "check mysql-server status: stopped"
  status=$(status_mysqld     ${master})
  assertEquals "stopped"    "${status}"

  echo "check zabbix-server status: stopped"
  status=$(status_zabbix     ${master})
  assertEquals "stopped"    "${status}"

  echo "check httpd status: stopped"
  status=$(status_httpd      ${master})
  assertEquals "stopped"    "${status}"

  echo "check keepalived status: stopped"
  status=$(status_keepalived ${master})
  assertEquals "running..." "${status}"
}

function before_check_master_interface() {
  echo "before check master interface"
  echo "check virtual ipaddress: public"
  show_virtual_ipaddr ${master} ${pifname}
  assertEquals 0 $?

  echo "check virtual ipaddress: wakame"
  show_virtual_ipaddr ${master} ${wifname}
  assertEquals 0 $?
}

function before_check_backup_interface() {
  echo "before check backup interface"
  echo "check virtual ipaddress: public none"
  show_virtual_ipaddr ${backup} ${pifname}
  assertEquals 1 $?

  echo "check virtual ipaddress: wakame none"
  show_virtual_ipaddr ${backup} ${wifname}
  assertEquals 1 $?
}

function after_check_master_interface() {
  echo "after check master interface"
  echo "check virtual ipaddress: public"
  show_virtual_ipaddr ${backup} ${pifname}
  assertEquals 0 $?

  echo "check virtual ipaddress: wakame"
  show_virtual_ipaddr ${backup} ${wifname}
  assertEquals 0 $?
}

function after_check_backup_interface() {
  echo "after check backup interface"
  echo "check virtual ipaddress: public none"
  show_virtual_ipaddr ${master} ${pifname}
  assertEquals 1 $?

  echo "check virtual ipaddress: wakame none"
  show_virtual_ipaddr ${master} ${wifname}
  assertEquals 1 $?
}

function before_check_master_repl() {
  echo "before check master repl"
  echo "check rpl_semi_sync_master_enabled: ON"
  enabled=$(check_rpl_variables ${master} name="master" value="enabled")
  assertEquals "ON"  "${enabled}"

  echo "check rpl_semi_sync_slave_enabled: OFF"
  enabled=$(check_rpl_variables ${master} name="slave"  value="enabled")
  assertEquals "OFF" "${enabled}"

  echo "check Rpl_semi_sync_master_status: ON"
  status=$(check_rpl_status ${master} name="master")
  assertEquals "ON" "${status}"

  echo "check Rpl_semi_sync_slave_status: OFF"
  status=$(check_rpl_status ${master} name="slave" )
  assertEquals "OFF" "${status}"
}

function before_check_backup_repl() {
  echo "before check backup repl"
  echo "check rpl_semi_sync_master_enabled: OFF"
  enabled=$(check_rpl_variables ${backup} name="master" value="enabled")
  assertEquals "OFF" "${enabled}"

  echo "check rpl_semi_sync_slave_enabled: ON"
  enabled=$(check_rpl_variables ${backup} name="slave"  value="enabled")
  assertEquals "ON"  "${enabled}"

  echo "check Rpl_semi_sync_master_status: OFF"
  status=$(check_rpl_status ${backup} name="master")
  assertEquals "OFF" "${status}"

  echo "check Rpl_semi_sync_slave_status: ON"
  status=$(check_rpl_status ${backup} name="slave" )
  assertEquals "ON"  "${status}"
}

function after_check_master_repl() {
  echo "after check master repl"
  echo "check rpl_semi_sync_master_enabled: ON"
  enabled=$(check_rpl_variables ${backup} name="master" value="enabled")
  assertEquals "ON"  "${enabled}"

  echo "check rpl_semi_sync_slave_enabled: OFF"
  enabled=$(check_rpl_variables ${backup} name="slave"  value="enabled")
  assertEquals "OFF" "${enabled}"
}

function check_executed_gtid_set() {
  echo "check executed gtid set"
  mgtid=$(check_master_gtid ${master})
  sgtid=$(check_slave_gtid  ${backup})
  assertEquals "${mgtid}" "${sgtid}"
}

function wait_sec() {
  local sec=${1}
  echo "wait ${sec} sec"
  sleep ${sec}
}
