#!/bin/bash
#
#       * File     : natmap_callback.sh
#       * Author   : sunowsir
#       * Mail     : sunowsir@163.com
#       * Github   : github.com/sunowsir
#       * Creation : Fri 20 Dec 2024 02:55:51 PM CST



WORK_DIR="$(dirname $(readlink -f "${0}"))"
source "${WORK_DIR}/natmap_notify_script_config.sh"

TMP_DIR="/tmp"
LOCK_FILE="${TMP_DIR}/.openwrt.natmap.callback.script.lock"

mkdir -p ${LOGS_SAVE_DIR}
LOG_FILE="${LOGS_SAVE_DIR}/.openwrt.natmap.callback.script.log"

WORK_SH_FILE="natmap_after_setup.sh"

FILE_IDLE="$(( $(date '+%s') - $(date -r "${LOG_FILE}" '+%s' 2>/dev/null || echo '0') ))"

# 日志保存两小时
[[ ${FILE_IDLE} -gt ${LOGS_SAVE_TIMES} ]] && \
    rm -rf ${LOG_FILE}

flock ${LOCK_FILE} ${WORK_DIR}/${WORK_SH_FILE} ${@} >> ${LOG_FILE} 2>&1 
