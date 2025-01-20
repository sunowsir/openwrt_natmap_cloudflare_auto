#!/bin/bash
#
#       * File     : natmap_notify.sh
#       * Author   : sunowsir
#       * Mail     : sunowsir@163.com
#       * Github   : github.com/sunowsir
#       * Creation : Fri 19 Dec 2024 19:21:47 PM CST

source "${WORK_DIR}/natmap_notify_script_config.sh"

Natmap_addr="${1}"
Natmap_port="${2}"

function sc_send_proc() {
    local text=$1
    local desp=$2
    local key=$3

    local postdata="text=$text&desp=$desp"
    local opts=(
        "--header" "Content-type: application/x-www-form-urlencoded"
        "--data" "$postdata"
    )

    # 判断 key 是否以 "sctp" 开头，选择不同的 URL
    local url="https://sctapi.ftqq.com/${key}.send"
    if [[ "$key" =~ ^sctp([0-9]+)t ]]; then
        # 使用正则表达式提取数字部分
        local num=${BASH_REMATCH[1]}
        url="https://${num}.push.ft07.com/send/${key}.send"
    fi


    # 使用动态生成的 url 发送请求
    local result=$(curl -X POST -s -o /dev/null -w "%{http_code}" "$url" "${opts[@]}")
    echo "$result"
}


function sc_send() {
    local public_ipv4="${1}"
    local public_port="${2}"
    local private_ipv4="${6}"
    local protocol="${5}"
    local private_port="${4}"

    # 调用sc_send函数
    local ret=$(sc_send_proc 'Natmap 映射已更新' \
        "${protocol}: ${private_ipv4}:${private_port} --> ${public_ipv4}:${public_port}"$'\n\n' \
	"$SENDKEY")
    if [[ ${ret} -ne 200 ]]; then
        echo "send ${*} error: ${ret}" > /var/log/natmap_notify.log
	return -1
    fi
    return 0
}

function firewall_rules_add() {
    local private_port="${4}"

    # 1. 检查是否已经存在同名规则
    if ! uci show firewall | grep -q "firewall.@rule\[.*\].name='Allow-${private_port}'"; then
        # 2. 添加规则
        uci add firewall rule
        uci set firewall.@rule[-1].name="Allow-${private_port}"
        uci set firewall.@rule[-1].src='wan'
        uci set firewall.@rule[-1].dest_port="${private_port}"
        uci set firewall.@rule[-1].target='ACCEPT'

        # 3. 提交并重启防火墙
        uci commit firewall
        service firewall restart
    fi

    return $?
}

function main() {
    sc_send ${@}
    firewall_rules_add ${@}
    return $?
}

main ${@}
exit $?
