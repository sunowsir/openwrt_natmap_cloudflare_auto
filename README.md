# openwrt natmap 通知及自动配置脚本
* 端口号变更后自动更新cloudflare 301 转发规则并发送server酱通知

    > 1. natmap 脚本运行时，请勿删除日志文件
    > 否则可能会导致脚本执行冲突导致规则更新冲突
    > 2. !!! 稳妥起见，请仅修改配置文件`natmap_callback.config`，其他勿动
    > 3. 配置文件中的AUTH ZONE 等相关cloudflare的账户认证ID必须填写完毕才能使用，具体获取方式见鸣谢博客教程以及配置文件`natmap_callback.config`注释

    1. 支持自动增加或修改 cloudflare DNS记录，若已存在记录则修改，否则新增
    2. 支持发送server chan通知
    3. 支持增加openwrt防火墙规则
    4. 支持增加或修改cloudflare转发规则，若存在重复规则则修改，否则新增
    5. 支持未在配置文件中配置子域名时仅发送server chan通知

* ddns 请自行解决，使用luci-app-ddns或luci-app-ddns-go或者其他脚本或插件

---

鸣谢:
* [在NAT 1内网IP宽带上部署Web服务并使用CloudFlare进行重定向](https://blog.dibin.eu.org/posts/%E5%9C%A8NAT-1%E5%86%85%E7%BD%91IP%E5%AE%BD%E5%B8%A6%E4%B8%8A%E9%83%A8%E7%BD%B2Web%E6%9C%8D%E5%8A%A1%E5%B9%B6%E4%BD%BF%E7%94%A8Cloudflare%E8%BF%9B%E8%A1%8C%E9%87%8D%E5%AE%9A%E5%90%91/)
