#!/bin/bash

# Ensure environment variables are set
if [[ -z "$SSH_SERVER" || -z "$SSH_USER" || -z "$SSH_PASS" ]]; then
  echo "❌ Error: SSH_SERVER, SSH_USER, or SSH_PASS is not set!"
  exit 1
fi

# 读取 Secrets，并按逗号分割存入数组
IFS=',' read -ra servers <<< "$SSH_SERVER"
IFS=',' read -ra users <<< "$SSH_USER"
IFS=',' read -ra passwords <<< "$SSH_PASS"

# 确保数组长度一致
if [[ ${#servers[@]} -ne ${#users[@]} || ${#servers[@]} -ne ${#passwords[@]} ]]; then
  echo "❌ Error: SSH_SERVER, SSH_USER, SSH_PASS 数量不匹配!"
  exit 1
fi

# 遍历服务器、用户和密码
for i in "${!servers[@]}"; do
  SERVER="${servers[$i]}"
  USER="${users[$i]}"
  PASS="${passwords[$i]}"

  echo "🔄 正在尝试登录: 用户: $USER 服务器: $SERVER ..."

  # 使用 sshpass 执行 SSH，并捕获状态
  sshpass -p "$PASS" ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -tt "$USER@$SERVER" << EOF
    echo "✅ 登录成功 - 用户: $USER"
    ls -lah
    exit
EOF

  SSH_STATUS=$?
  
  if [ $SSH_STATUS -eq 0 ]; then
    echo "✅ 用户 $USER 在 $SERVER 登录成功!"
  else
    echo "❌ 用户 $USER 在 $SERVER 登录失败!"
  fi

  echo "----------------------------------------"
done
