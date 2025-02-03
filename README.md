# openwrt natmap 通知及自动配置脚本
* 端口号变更后自动更新cloudflare 301 转发规则并发送server酱通知

    > 1. 使用前请仔仔细细阅读如下鸣谢提及的博客，本项目由该博客启发而来
    > 2. natmap 脚本运行时，请勿删除flock锁文件
    > 否则可能会导致脚本执行冲突导致规则更新冲突
    > 3. !!! 稳妥起见，请仅修改配置文件`/etc/config/natmap_callback`，其他勿动
    > 4. 配置文件中的AUTH ZONE 等相关cloudflare的账户认证ID以及其他配置必须全部填写完毕才能正常使用，具体获取方式见鸣谢博客教程以及配置文件`natmap_callback.config`注释

    1. 支持自动增加或修改 cloudflare DNS记录（访问域名，而不是转发域名），若已存在记录则修改，否则新增
    2. 支持发送server chan通知
    3. 支持增加openwrt防火墙规则
    4. 支持增加或修改cloudflare转发规则，若存在重复规则则修改，否则新增
    5. 支持未在配置文件中配置子域名时仅发送server chan通知
    6. natmap 配置例如：
    ``` txt
    config natmap
        option udp_mode '0'
        option stun_server 'turn.cloudflare.com'
        option http_server 'qq.com'
        option port '18080'
        option family 'ipv4'
        option interface 'wan'
        option forward_target '127.0.0.1'
        option forward_port '8080'
        option notify_script '/etc/natmap_callback/natmap_callback'
        option enable '1'

    ```

* 转发域名的 `ddns` 请自行解决（懒得搞，改天的吧），使用luci-app-ddns或luci-app-ddns-go或者其他脚本或插件

---

注意：
1. `natmap`指的是内网穿透的核心插件
2. `natmap_callback`指的是本项目，本项目依托于`natmap`而存在，作为`natmap`的通知脚本而存在

鸣谢（顺序不分先后）:
* [natmap](https://github.com/heiher/natmap)
* [Cloudflare](https://www.cloudflare.com)
* [在NAT 1内网IP宽带上部署Web服务并使用CloudFlare进行重定向](https://blog.dibin.eu.org/posts/%E5%9C%A8NAT-1%E5%86%85%E7%BD%91IP%E5%AE%BD%E5%B8%A6%E4%B8%8A%E9%83%A8%E7%BD%B2Web%E6%9C%8D%E5%8A%A1%E5%B9%B6%E4%BD%BF%E7%94%A8Cloudflare%E8%BF%9B%E8%A1%8C%E9%87%8D%E5%AE%9A%E5%90%91)
* [server酱](https://sct.ftqq.com)

