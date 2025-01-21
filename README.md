# openwrt natmap 通知及自动配置脚本
* 端口号变更后自动更新cloudflare 301 转发规则并发送server酱通知
    > 1. natmap 脚本运行时，请勿删除`/tmp/.openwrt.natmap.callback.script.lock`，
    > 否则可能会导致脚本执行冲突导致规则更新冲突
    > 2. !!! 稳妥起见，请仅修改配置文件`natmap_notify_script_config.sh`，其他勿动
    1. flock 上锁，标准输出和标准错误重定向到 `/tmp/.openwrt.natmap.callback.script.log`
    2. 发送server酱通知
    3. 获取现有规则列表
    4. 定义新规则
    5. 检查是否存在相同描述的规则
        1. 检查是否存在相同描述的规则
        2. 若描述相同的规则已存在，则替换旧规则
        3. 若规则不存在，则追加新规则
    6. 提交更新后的规则
    7. 增加防火墙放行规则
* ddns 请自行解决，使用luci-app-ddns或luci-app-ddns-go或者其他脚本或插件

-- 

鸣谢:
* [在NAT 1内网IP宽带上部署Web服务并使用CloudFlare进行重定向](https://blog.dibin.eu.org/posts/%E5%9C%A8NAT-1%E5%86%85%E7%BD%91IP%E5%AE%BD%E5%B8%A6%E4%B8%8A%E9%83%A8%E7%BD%B2Web%E6%9C%8D%E5%8A%A1%E5%B9%B6%E4%BD%BF%E7%94%A8Cloudflare%E8%BF%9B%E8%A1%8C%E9%87%8D%E5%AE%9A%E5%90%91/)
