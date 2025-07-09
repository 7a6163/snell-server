# 設置指南 / Setup Guide

## 🚀 快速開始 / Quick Start

### 1. Fork 這個倉庫 / Fork this repository
點擊 GitHub 頁面右上角的 "Fork" 按鈕

### 2. 設置 Secrets / Setup Secrets

在你的 GitHub 倉庫中，進入 **Settings** → **Secrets and variables** → **Actions**

#### 🐳 Docker Hub 設置
添加以下 secrets：
- `DOCKERHUB_USERNAME`: 你的 Docker Hub 用戶名
- `DOCKERHUB_TOKEN`: 你的 Docker Hub 訪問令牌

**如何獲取 Docker Hub Token:**
1. 登錄 [Docker Hub](https://hub.docker.com/)
2. 點擊右上角頭像 → **Account Settings**
3. 選擇 **Security** 標籤
4. 點擊 **New Access Token**
5. 輸入描述並選擇權限（建議選擇 **Read, Write, Delete**）
6. 複製生成的 token

#### 🐙 GitHub Container Registry 設置
**無需額外設置！** GitHub Actions 會自動使用 `GITHUB_TOKEN`

### 3. 啟用 GitHub Container Registry / Enable GHCR

確保你的 GitHub 賬戶已啟用 Container Registry：
1. 進入 GitHub 個人設置 → **Developer settings** → **Personal access tokens**
2. 確保你的 token 有 `write:packages` 權限

### 4. 創建發布 / Create Release

推送一個版本標籤來觸發自動構建：

```bash
# 創建並推送標籤
git tag v5.0.0b3
git push origin v5.0.0b3
```

## 🔄 自動化流程 / Automation Workflow

推送標籤後，GitHub Actions 會自動：

1. **🏗️ 構建多架構鏡像** (linux/amd64, linux/arm64)
2. **🔍 安全掃描** 使用 Trivy
3. **📦 發布到兩個註冊表**:
   - Docker Hub: `your-username/snell-server:v5.0.0b3`
   - GitHub Container Registry: `ghcr.io/your-username/snell-server:v5.0.0b3`
4. **📝 創建 GitHub Release** 包含使用說明

## 🎯 使用發布的鏡像 / Using Released Images

### Docker Hub
```bash
docker pull your-username/snell-server:latest
```

### GitHub Container Registry
```bash
docker pull ghcr.io/your-username/snell-server:latest
```

## 🛠️ 本地開發 / Local Development

```bash
# 使用自動化腳本
./setup.sh

# 或手動構建
docker build --platform linux/amd64 -t snell-server .
docker run -d --name snell-server -p 6160:6160 snell-server
```

## 🔧 故障排除 / Troubleshooting

### 常見問題 / Common Issues

1. **Docker Hub 推送失敗**
   - 檢查 `DOCKERHUB_USERNAME` 和 `DOCKERHUB_TOKEN` 是否正確設置
   - 確保 Docker Hub token 有寫入權限

2. **GitHub Container Registry 推送失敗**
   - 檢查倉庫的 Actions 權限設置
   - 確保 `GITHUB_TOKEN` 有 `write:packages` 權限

3. **多架構構建失敗**
   - 檢查 Dockerfile 中的架構參數
   - 確保目標架構的二進制文件可用

### 查看構建日誌 / View Build Logs

1. 進入你的 GitHub 倉庫
2. 點擊 **Actions** 標籤
3. 選擇失敗的工作流程
4. 查看詳細日誌

## 📞 獲取幫助 / Get Help

如果遇到問題，可以：
1. 查看 [GitHub Issues](../../issues)
2. 閱讀 [README.md](README.md) 的詳細文檔
3. 檢查 GitHub Actions 的構建日誌
