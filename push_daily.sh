#!/bin/bash
# 推送每日报告到 GitHub 仓库 sunyongan123/AI-Daily
# 用法: bash push_daily.sh [日期YYYY-MM-DD]
set -e

cd "D:/Workbuddy workspace/Hotspot Summary"

DATE_ARG="${1:-$(date +%F)}"
REPORT="reports/${DATE_ARG}-科研AI前沿日报.html"

export GIT_SSH_COMMAND="ssh -i $HOME/.ssh/github_daily_ed25519 -o IdentitiesOnly=yes -o StrictHostKeyChecking=accept-new"

# 确保远程为 SSH
git remote set-url origin git@github.com:sunyongan123/AI-Daily.git 2>/dev/null || true

# 先拉取远端最新（避免冲突）
git pull --rebase origin main 2>/dev/null || true

git add -A
if git diff --cached --quiet; then
  echo "无变更，跳过提交"
  exit 0
fi

git commit -m "日报: ${DATE_ARG}" || true

# 推送（重试3次）
for i in 1 2 3; do
  if git push origin main 2>&1; then
    echo "✅ 推送成功"
    exit 0
  fi
  echo "⚠️  第 $i 次推送失败，5秒后重试..."
  sleep 5
done

echo "❌ 推送失败"
exit 1
