```markdown
# V2Ray + Komari Agent Docker 镜像 

这是一个集成了 V2Ray 代理和 Komari Agent 监控的 Docker 镜像，使用 Nginx 作为 WebSocket 反向代理。

## 功能特性

- **V2Ray 代理**：支持 VMESS 和 VLESS 协议，通过 WebSocket 传输
- **Nginx 反向代理**：处理 WebSocket 连接，隐藏后端服务
- **Komari 监控**：可选集成 Komari Agent，实时监控服务器状态
- **自动化配置**：通过环境变量灵活配置所有参数

## 环境变量说明

### V2Ray 配置变量

| 变量名 | 是否必填 | 默认值 | 说明 |
|--------|---------|--------|------|
| `UUID` | 可选 | `de04add9-5c68-8bab-950c-08cd5320df18` | V2Ray 客户端连接的唯一标识符，建议自定义 |
| `VMESS_WSPATH` | 可选 | `/vmess` | VMESS 协议的 WebSocket 路径 |
| `VLESS_WSPATH` | 可选 | `/vless` | VLESS 协议的 WebSocket 路径 |

**UUID 生成建议：**
```bash
# Linux/macOS
cat /proc/sys/kernel/random/uuid

# 或使用在线工具
# https://www.uuidgenerator.net/
```

### Komari Agent 监控变量

| 变量名 | 是否必填 | 默认值 | 说明 |
|--------|---------|--------|------|
| `KOMARI_ENDPOINT` | 必填* | 无 | Komari Dashboard 服务器地址（格式：`http://server:25774`） |
| `KOMARI_TOKEN` | 必填* | 无 | Komari Dashboard 自动发现密钥（AD Key） |
| `KOMARI_ENABLE_WEBSSH` | 可选 | `false` | 是否启用 WebSSH 远程控制功能，设为 `true` 启用 |

> **注意**：只有同时设置 `KOMARI_ENDPOINT` 和 `KOMARI_TOKEN` 时，Komari Agent 才会启动。如果不设置这两个变量，容器仍会正常运行，只是没有监控功能。

**安全说明：**
- **WebSSH 默认禁用**：出于安全考虑，Docker 环境下默认禁用 WebSSH 远程控制功能
- **自动更新已禁用**：容器内 Komari Agent 自动更新功能已禁用，请通过重建镜像升级

## 使用示例

### 示例 1：仅使用 V2Ray（无监控）

```bash
docker run -d \
  --name v2ray-proxy \
  -p 80:80 \
  -e UUID="your-custom-uuid-here" \
  -e VMESS_WSPATH="/custom-vmess-path" \
  -e VLESS_WSPATH="/custom-vless-path" \
  your-image-name
```

### 示例 2：V2Ray + Komari 监控（WebSSH 禁用）

```bash
docker run -d \
  --name v2ray-with-monitor \
  -p 80:80 \
  -e UUID="your-custom-uuid-here" \
  -e VMESS_WSPATH="/vmess" \
  -e VLESS_WSPATH="/vless" \
  -e KOMARI_ENDPOINT="http://monitor.example.com:25774" \
  -e KOMARI_TOKEN="your-komari-token-here" \
  your-image-name
```

### 示例 3：完整配置（启用 WebSSH）

```bash
docker run -d \
  --name v2ray-full \
  -p 80:80 \
  -e UUID="12345678-1234-1234-1234-123456789abc" \
  -e VMESS_WSPATH="/my-vmess" \
  -e VLESS_WSPATH="/my-vless" \
  -e KOMARI_ENDPOINT="http://192.168.1.100:25774" \
  -e KOMARI_TOKEN="ad-key-from-dashboard" \
  -e KOMARI_ENABLE_WEBSSH="true" \
  your-image-name
```

### 示例 4：Docker Compose

```yaml
version: '3'
services:
  v2ray-proxy:
    image: your-image-name
    ports:
      - "80:80"
    environment:
      - UUID=your-custom-uuid
      - VMESS_WSPATH=/vmess
      - VLESS_WSPATH=/vless
      - KOMARI_ENDPOINT=http://monitor.example.com:25774
      - KOMARI_TOKEN=your-token-here
      # - KOMARI_ENABLE_WEBSSH=true  # 需要时取消注释
    restart: unless-stopped
```

## V2Ray 客户端配置

连接到此服务需要配置：
- **地址**：您的服务器 IP 或域名
- **端口**：80
- **UUID**：与环境变量 `UUID` 相同
- **传输协议**：WebSocket (ws)
- **WebSocket 路径**：`/vmess`（VMESS）或 `/vless`（VLESS）

## Komari Dashboard 配置

在 Komari Dashboard 中获取连接信息：

1. 登录 Komari Dashboard
2. 进入「设置」→「Agent」→「自动发现」
3. 复制「AD Key」作为 `KOMARI_TOKEN`
4. Dashboard 地址和端口组合为 `KOMARI_ENDPOINT`（默认端口 25774）

## 常见问题

**Q: 不设置 Komari 变量会影响 V2Ray 吗？**  
A: 不会。Komari Agent 是可选功能，不设置相关变量时只运行 V2Ray 和 Nginx。

**Q: 如何验证 Komari Agent 是否运行？**  
A: 查看容器日志 `docker logs <container-name>` 或在 Komari Dashboard 中查看设备是否在线。

**Q: 可以修改 Nginx 端口吗？**  
A: 可以通过 `-p 8080:80` 将容器 80 端口映射到宿主机 8080 端口。

**Q: UUID 可以在容器运行后修改吗？**  
A: 需要重启容器并重新设置环境变量，或者直接重新创建容器。

**Q: WebSSH 功能安全吗？**  
A: WebSSH 允许通过 Dashboard 远程执行命令，生产环境建议保持默认禁用状态。

## 安全建议

1. **自定义 UUID**：不要使用默认 UUID，建议生成随机 UUID
2. **自定义路径**：修改 WebSocket 路径增加隐蔽性
3. **禁用 WebSSH**：生产环境保持 WebSSH 禁用状态
4. **HTTPS 部署**：建议在前端添加 HTTPS 反向代理（如 Caddy、Traefik）
5. **防火墙规则**：仅开放必要端口

## 技术架构

```
客户端请求 → Nginx (80端口) → WebSocket 代理 → V2Ray (10000/20000端口)
                                              ↓
                                      Komari Agent → Dashboard
```

## 构建镜像

```bash
# 克隆仓库
git clone <your-repo-url>
cd <repo-directory>

# 构建镜像
docker build -t v2ray-komari:latest .

# 运行容器
docker run -d -p 80:80 \
  -e UUID="your-uuid" \
  -e KOMARI_ENDPOINT="http://monitor.example.com:25774" \
  -e KOMARI_TOKEN="your-token" \
  v2ray-komari:latest
```

## 更新日志

- 将 Nezha Agent 替换为 Komari Agent
- 优化环境变量设计，简化配置
- 增强安全性，默认禁用 WebSSH
- 支持自动获取最新版本的 V2Ray 和 Komari Agent

## 许可证

请遵守相关开源协议和当地法律法规。

## 致谢

- [V2Ray](https://github.com/v2fly/v2ray-core)
- [Komari Monitor](https://github.com/komari-monitor/komari)
- [Nginx](https://nginx.org/)
```

这个README文件可以直接复制粘贴到您的GitHub仓库中使用，包含了完整的变量说明、使用示例、常见问题和安全建议等内容。[7][8]

[1](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/133627315/eac364f0-5416-4863-9785-1a0c90a83352/entrypoint.sh)
[2](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/133627315/27492437-c6ea-41a6-8a47-447818de9eb7/nginx.conf)
[3](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/133627315/f42d0888-e73b-41b4-999a-5a3c19cf1fd0/Dockerfile.txt)
[4](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/133627315/437f4b81-0638-4751-8198-df8d41985583/entrypoint.sh)
[5](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/133627315/642f960f-1d53-40d9-aa13-2e8173a68566/nginx.conf)
[6](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/133627315/a3a035f4-1c98-4a37-a984-86b512a5f34d/Dockerfile.txt)
[7](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/133627315/7b3d33ef-8635-4b38-9c18-85e23c8a3036/Dockerfile-1.txt)
[8](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/133627315/09767afd-6139-4f79-ac12-3ec63328d946/entrypoint-1.sh)
