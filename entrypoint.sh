#!/usr/bin/env bash

# 定义 UUID 及 伪装路径,请自行修改.(注意:伪装路径以 / 符号开始,为避免不必要的麻烦,请不要使用特殊符号.)

base64 -d config > config.json

UUID=${UUID:-'de04add9-5c68-8bab-950c-08cd5320df18'}
VMESS_WSPATH=${VMESS_WSPATH:-'/vmess'}
VLESS_WSPATH=${VLESS_WSPATH:-'/vless'}

sed -i "s#UUID#$UUID#g;s#VMESS_WSPATH#${VMESS_WSPATH}#g;s#VLESS_WSPATH#${VLESS_WSPATH}#g" config.json
sed -i "s#VMESS_WSPATH#${VMESS_WSPATH}#g;s#VLESS_WSPATH#${VLESS_WSPATH}#g" /etc/nginx/nginx.conf

# 伪装 v2ray 执行文件
RELEASE_RANDOMNESS=$(tr -dc 'A-Za-z0-9' </dev/urandom | head -c 6)
mv v ${RELEASE_RANDOMNESS}
cat config.json | base64 > config
rm -f config.json

# Komari Agent 配置和启动
KOMARI_ARGS="--disable-auto-update"
if [ "${KOMARI_ENABLE_WEBSSH}" != "true" ]; then
    KOMARI_ARGS="${KOMARI_ARGS} --disable-web-ssh"
fi
[ -n "${KOMARI_ENDPOINT}" ] && [ -n "${KOMARI_TOKEN}" ] && \
    ./komari-agent -e ${KOMARI_ENDPOINT} -t ${KOMARI_TOKEN} ${KOMARI_ARGS} &

# 运行 nginx 和 v2ray
nginx
base64 -d config > config.json
./${RELEASE_RANDOMNESS} run
