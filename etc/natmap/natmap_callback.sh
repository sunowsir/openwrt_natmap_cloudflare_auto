#!/bin/bash
#
#       * File     : natmap_callback.sh
#       * Author   : sunowsir
#       * Mail     : sunowsir@163.com
#       * Github   : github.com/sunowsir
#       * Creation : Fri 20 Dec 2024 02:55:51 PM CST

flock /tmp/.openwrt.immortalwrt.natmap.callback.script.lock /etc/natmap/natmap_after_setup.sh ${@} > /tmp/.openwrt.immortalwrt.natmap.callback.script.log 2>&1 
