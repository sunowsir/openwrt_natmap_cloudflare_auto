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
