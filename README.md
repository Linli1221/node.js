---
title: One-API with Caddy Proxy
emoji: 🚀
colorFrom: blue
colorTo: green
sdk: docker
app_port: 7860
---

# One-API with Smart Caddy Proxy

基于 Python 3.11 的 One-API 服务，内置智能 Caddy 反向代理。

## 功能特性

- **智能路由**: Caddy 通过 HTTP Header 识别来自 EdgeOne CDN 的流量并路由到内置的 one-api 服务
- **下游应用支持**: 将所有非 CDN 流量路由到下游应用指定的端口
- **权限管理**: 建立了健壮的权限模型，支持非 root 环境运行
- **服务时序**: 解决了服务启动的时序问题，确保代理在后端服务就绪后再启动
- **静默日志**: 实现了完全静默的日志输出

## 环境变量

- `DOWNSTREAM_PORT`: 下游应用端口 (默认: 3002)

## 路由规则

- EdgeOne CDN 流量 (带有 `Cdn-Loop *TencentEdgeOne*` header) → localhost:3001 (one-api 服务)
- 其他流量 → localhost:${DOWNSTREAM_PORT} (下游应用)
