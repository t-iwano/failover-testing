#!/bin/bash
#
# requires:
#   bash
#

## include files

## variables

## functions

function show_virtual_ipaddr() {
  local node=${1} local ifname=${2}
  show_ipaddr ${node} ifname=${ifname} | grep -w "${ifname}:1"
}

