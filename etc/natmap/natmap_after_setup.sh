#!/bin/bash
#
#       * File     : natmap_after_setup.sh
#       * Author   : sunowsir
#       * Mail     : sunowsir@163.com
#       * Github   : github.com/sunowsir
#       * Creation : Fri 20 Dec 2024 01:24:17 PM CST

set -x

WORK_DIR="$(dirname $(readlink -f "${0}"))"
source "${WORK_DIR}/natmap_notify_script_config.sh"

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
        echo "send ${*} error: ${ret}" 
        return -1
    fi

    return 0
}

# 获取现有规则列表
function currlent_rules_get() {
    local current_rules=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/${ZONE}/rulesets/${RULE}" \
        -H "Authorization: Bearer ${AUTH}" \
        -H "Content-Type: application/json" | jq '.result.rules')

    echo "${current_rules}"
}

# 定义新规则
function new_rule_make() {
    local PORT=${1}
    # 访问域名
    local ACCESS_DOMAIN="${2}"
    # 规则名称
    local RULE_NAME="${3}"

    local new_rule="{\"expression\":\"(http.request.full_uri wildcard r\\\"http*://${ACCESS_DOMAIN}/*\\\")\",\"description\":\"${RULE_NAME}\",\"action\":\"redirect\",\"action_parameters\":{\"from_value\":{\"target_url\":{\"expression\":\"wildcard_replace(http.request.full_uri, r\\\"http*://${ACCESS_DOMAIN}/*\\\", r\\\"https://${REDIRECT_DOMAIN}:${PORT}/\${2}\\\")\"},\"status_code\":301,\"preserve_query_string\":true}}}"

    echo "${new_rule}"
}

# 检查是否存在相同描述的规则
function same_rules_check() {
    local current_rules="${1}"   # 当前规则 JSON 数据
    local new_rule="${2}"       # 新规则 JSON 数据
    local RULE_NAME="${3}"      # 规则名称

    # 检查是否存在相同描述的规则
    local rule_exists
    rule_exists=$(echo "$current_rules" | jq --arg rule_name "$RULE_NAME" '[.[] | select(.description == $rule_name)]')

    local updated_rules

    if [[ $(echo "$rule_exists" | jq 'length') -gt 0 ]]; then
        # 若描述相同的规则已存在，则替换旧规则
        updated_rules=$(echo "$current_rules" | jq --argjson new_rule "$new_rule" --arg rule_name "$RULE_NAME" \
            'map(if .description == $rule_name then $new_rule else . end)')
    else
        # 若规则不存在，则追加新规则
        updated_rules=$(echo "$current_rules" | jq --argjson new_rule "$new_rule" '. += [$new_rule]')
    fi

    echo "${updated_rules}"
}

# 提交更新后的规则
function push_new_rules() {
    local updated_rules="${1}"

    curl -X PUT "https://api.cloudflare.com/client/v4/zones/${ZONE}/rulesets/${RULE}" \
        -H "Authorization: Bearer ${AUTH}" \
        -H "Content-Type: application/json" \
        --data "{\"name\":\"default\",\"kind\":\"zone\",\"phase\":\"http_request_dynamic_redirect\",\"rules\":${updated_rules}}" 
    
    return $?
}

# Redirect rule
function redirect_rule_setup_proc() {
    # 映射端口
    local PORT=${2}
    # 访问域名
    local ACCESS_DOMAIN="${3}.${ROOT_DOMAIN}"
    # 规则名称
    local RULE_NAME="${3}"

    for ((i = 0; i < ${RETRY_NUM}; i++)); do
        # 获取现有规则列表
        local current_rules="$(currlent_rules_get)"

        # 定义新规则
        local new_rule="$(new_rule_make "${PORT}" "${ACCESS_DOMAIN}" "${RULE_NAME}")"

        # 检查是否存在相同描述的规则
        local updated_rules="$(same_rules_check "${current_rules}" "${new_rule}" "${RULE_NAME}")"

        # 提交更新后的规则
        push_new_rules "${updated_rules}"

        if [[ ${?} -eq 0 ]]; then
            break;
        fi
    done

    return $?
}

# DNS
function redirect_domain_dns_records() {
    # 映射地址
    local ADDR=${1}

    for ((i = 0; i < ${RETRY_NUM}; i++)); do
        curl -X PUT "https://api.cloudflare.com/client/v4/zones/${ZONE}/dns_records/${RECORD}" \
            -H "X-Auth-Email: ${EMAIL}" \
            -H "Authorization: Bearer ${AUTH}" \
            -H "Content-Type:application/json" \
            --data "{\"type\":\"A\",\"name\":\"${REDIRECT_DOMAIN}\",\"content\":\"${ADDR}\",\"ttl\":auto,\"proxied\":false}" 

        if [[ ${?} -eq 0 ]]; then
            break;
        fi
    done

    return $?
}

function redirect_rule_setup() {
    local public_ipv4="${1}"
    local public_port="${2}"
    local private_ipv4="${6}"
    local protocol="${5}"
    local private_port="${4}"

    if [[ "${private_port}" == "" ]]; then
        echo "private_port is NULL"
        return -1
    fi

    local sub_domain="${SERVICE_SUB_DOMAIN_DIC[${private_port}]}"

    if [[ "${sub_domain}" == "" ]]; then
        echo "sub_domain is empty, private_port is ${private_port}"
        return -1
    fi

    # redirect_domain_dns_records "${public_ipv4}" 
    redirect_rule_setup_proc "${public_ipv4}" "${public_port}" "${sub_domain}" 
     
    return $?
}

function firewall_rules_add() {
    local private_port="${4}"

    # 1. 检查是否已经存在同名规则
    if ! uci show firewall | grep -q "firewall.@rule\[.*\].name='Allow-${private_port}'"; then

        # 2. 添加通讯规则
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
    redirect_rule_setup ${@} || exit $?
    firewall_rules_add ${@} || exit $?

    # 只有成功才发通知
    sc_send ${@}

    return $?
}

echo "---"
echo "${@}"
echo "---"

main ${@}

set +x

exit $?
