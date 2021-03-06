# -*-Shell-script-*-
#
# requires:
#   bash
#

## system variables

readonly shunit2_file=${BASH_SOURCE[0]%/*}/shunit2

## include files

. ${BASH_SOURCE[0]%/*}/functions.sh

## environment-specific configuration

[[ -f ${BASH_SOURCE[0]%/*}/failover ]] && { . ${BASH_SOURCE[0]%/*}/failover; } || :

## group variables

## group functions

function setup_vars() {
  MASTER_HOST=${MASTER_HOST:-keepalived01}
  BACKUP_HOST=${BACKUP_HOST:-keepalived02}
  PUBLIC_INTERFACE=${PUBLIC_INTERFACE:-eth1}
  WAKAME_INTERFACE=${WAKAME_INTERFACE:-eth2}
  MYSQL_HOST=${MYSQL_HOST:-localhost}
  MYSQL_USER=${MYSQL_USER:-root}
  MYSQL_PASSWORD=${MYSQL_PASSWORD:-}
  MYSQL_DB=${MYSQL_DB:-zabbix}
  PROCESS_STOP_WAIT=${PROCESS_STOP_WAIT:-60}
  PROCESS_SETUP_WAIT=${PROCESS_SETUP_WAIT:-60}
  NETWORK_STOP_WAIT=${NETWORK_STOP_WAIT:-60}
  NETWORK_SETUP_WAIT=${NETWORK_SETUP_WAIT:-60}
}

function query_mysql() {
  local node=${1} local query=${2}
  declare mysql_opts=""

  [[ -n "${MYSQL_HOST}" ]] && {
    mysql_opts="${mysql_opts} --host=${MYSQL_HOST}"
  }
  [[ -n "${MYSQL_PASSWORD}" ]] && {
    mysql_opts="$mysql_opts --password=${MYSQL_PASSWORD}"
  }
  ssh ${node} <<-EOS
/usr/bin/mysql -s ${mysql_opts} --execute="${query}" -u${MYSQL_USER} ${MYSQL_DB}
EOS
}

function check_rpl_variables() {
  local node=${1}
  shift; eval local "${@}"
  query_mysql ${node} "show variables like 'rpl_semi_sync_${name}_${value}'" | awk '{print $NF}'
}

function check_rpl_status() {
  local node=${1}
  shift; eval local "${@}"
  query_mysql ${node} "show status like 'Rpl_semi_sync_${name}_status'" | awk '{print $NF}'
}


function check_master_gtid() {
  local node=${1}
  query_mysql ${node} "show master status" | awk '{print $NF}'
}

function check_slave_gtid() {
  local node=${1}
  query_mysql ${node} "show slave status" | awk '{print $(NF - 1)}'
}

##
setup_vars

