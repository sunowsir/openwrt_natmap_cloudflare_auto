#!/bin/bash
#
#	* File     : natmap_notify_script_config.sh
#	* Author   : sunowsir
#	* Mail     : sunowsir@163.com
#	* Github   : github.com/sunowsir
#	* Creation : Fri 20 Dec 2024 04:02:21 PM CST

# 教程: https://blog.dibin.eu.org/posts/%E5%9C%A8NAT-1%E5%86%85%E7%BD%91IP%E5%AE%BD%E5%B8%A6%E4%B8%8A%E9%83%A8%E7%BD%B2Web%E6%9C%8D%E5%8A%A1%E5%B9%B6%E4%BD%BF%E7%94%A8Cloudflare%E8%BF%9B%E8%A1%8C%E9%87%8D%E5%AE%9A%E5%90%91/

# 域名ZONE_ID， 在你的域名概览页面左下角可以找到 区域 ID 字样,复制下来并填入
ZONE=''
#  Cloudflare API
AUTH=''
# 账户邮箱
EMAIL=''
# 注册域名
ROOT_DOMAIN=''
# 转发域名
REDIRECT_DOMAIN="redirect.${ROOT_DOMAIN}"

# 规则编辑RULE_ID，添加完规则后，打开F12，点击编辑规则，网络中右边名称会多出来一个 entrypoint，复制id
RULE=''

# 转发域名的 RECORD_ID，F12，网络搜索dns_records，复制ID
RECORD=''

# 重试次数
RETRY_NUM=20

# server 酱通知
SENDKEY=''

# 如下方括号中的key,填写natmap配置文件/etc/config/natmap中的：
# option port '20809' 配置项目中的端口号
# 如下双引号中的value, 填写子域名名称，例如blog.yl0618.tech中的blog
declare -A SERVICE_SUB_DOMAIN_DIC
SERVICE_SUB_DOMAIN_DIC=(
    [28090]="blog"
)

# 其他步骤请参考最上面的教程
