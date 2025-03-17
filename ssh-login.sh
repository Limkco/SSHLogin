#!/bin/bash

# 读取 Secrets，并按逗号分割存入数组
IFS=',' read -ra servers <<< "$SSH_SERVER"
IFS=',' read -ra users <<< "$SSH_USER"
IFS=',' read -ra passwords <<< "$SSH_PASS"

# 确保数组长度一致
if [[ ${#servers[@]} -ne ${#users[@]} || ${#servers[@]} -ne ${#passwords[@]} ]]; then
  echo "Error: SSH_SERVER, SSH_USER, SSH_PASS 数量不匹配!"
  exit 1
fi

# 遍历服务器、用户和密码
for i in "${!servers[@]}"; do
  SERVER="${servers[$i]}"
  USER="${users[$i]}"
  PASS="${passwords[$i]}"

  echo "Logging in as $USER on $SERVER..."

  sshpass -p "$PASS" ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -tt "$USER@$SERVER" << EOF
      echo "登录成功 - 用户: $USER"
      ls -lah
      exit
EOF
done
