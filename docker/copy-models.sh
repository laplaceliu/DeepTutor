#!/bin/bash
# 复制本机 Ollama 模型到 docker 目录

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_DIR="$SCRIPT_DIR/ollama-data"

# 检测 Ollama 模型存储位置
OLLAMA_DIR=""
if [ -d "$HOME/.ollama/models" ]; then
    OLLAMA_DIR="$HOME/.ollama"
elif [ -d "/usr/share/ollama/.ollama/models" ]; then
    OLLAMA_DIR="/usr/share/ollama/.ollama"
else
    echo "❌ 未找到 Ollama 模型目录"
    exit 1
fi

if [ ! -d "$OLLAMA_DIR" ]; then
    echo "❌ 本机未找到 Ollama 目录: $OLLAMA_DIR"
    exit 1
fi

echo "📂 本机 Ollama 目录: $OLLAMA_DIR"
echo "📂 目标目录: $TARGET_DIR"
echo ""

# 清理旧数据
if [ -d "$TARGET_DIR" ]; then
    echo "🧹 清理旧数据..."
    rm -rf "$TARGET_DIR"
fi

# 创建目录
mkdir -p "$TARGET_DIR"

# 复制模型数据
echo "📦 复制模型文件..."
if [ -d "$OLLAMA_DIR/models" ]; then
    # 检查是否需要 sudo
    if [ ! -r "$OLLAMA_DIR/models" ]; then
        echo "   需要 sudo 权限复制模型..."
        sudo cp -r "$OLLAMA_DIR/models" "$TARGET_DIR/"
        sudo chown -R $(id -u):$(id -g) "$TARGET_DIR/models"
    else
        cp -r "$OLLAMA_DIR/models" "$TARGET_DIR/"
    fi
    echo "✅ 模型文件已复制"
fi

# 复制其他必要文件
for item in "id_ed25519.pub" "id_ed25519"; do
    if [ -f "$OLLAMA_DIR/$item" ]; then
        cp "$OLLAMA_DIR/$item" "$TARGET_DIR/"
    fi
done

echo ""
echo "✅ 复制完成！"
echo ""
echo "📊 复制的文件:"
du -sh "$TARGET_DIR" 2>/dev/null || echo "   (目录大小计算中...)"
echo ""
echo "🚀 现在可以运行: docker-compose up"
