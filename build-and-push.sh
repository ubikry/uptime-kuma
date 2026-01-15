#!/bin/bash

# 构建和推送 Uptime Kuma Docker 镜像到阿里云
# 用法: ./build-and-push.sh

set -e

# 颜色输出
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# 配置
ALIYUN_REGISTRY="registry.cn-hangzhou.aliyuncs.com"
ALIYUN_NAMESPACE="ubikry"
IMAGE_NAME="uptime-kuma"
VERSION=$(grep '"version":' package.json | head -1 | sed 's/.*"version": "\(.*\)".*/\1/')

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Uptime Kuma Docker 镜像构建与推送${NC}"
echo -e "${BLUE}========================================${NC}"
echo -e "${GREEN}版本: ${VERSION}${NC}"
echo ""

# 构建镜像
echo -e "${GREEN}[1/4] 开始构建 Docker 镜像...${NC}"
docker build \
    -f docker/dockerfile \
    --target release \
    -t ${IMAGE_NAME}:latest \
    -t ${IMAGE_NAME}:${VERSION} \
    .

echo -e "${GREEN}✓ 镜像构建完成${NC}"
echo ""

# 打标签到阿里云
echo -e "${GREEN}[2/4] 为阿里云仓库打标签...${NC}"
docker tag ${IMAGE_NAME}:latest ${ALIYUN_REGISTRY}/${ALIYUN_NAMESPACE}/${IMAGE_NAME}:latest
docker tag ${IMAGE_NAME}:${VERSION} ${ALIYUN_REGISTRY}/${ALIYUN_NAMESPACE}/${IMAGE_NAME}:${VERSION}

echo -e "${GREEN}✓ 标签创建完成${NC}"
echo ""

# 推送到阿里云
echo -e "${GREEN}[3/4] 推送 latest 标签到阿里云...${NC}"
docker push ${ALIYUN_REGISTRY}/${ALIYUN_NAMESPACE}/${IMAGE_NAME}:latest

echo -e "${GREEN}[4/4] 推送版本标签 ${VERSION} 到阿里云...${NC}"
docker push ${ALIYUN_REGISTRY}/${ALIYUN_NAMESPACE}/${IMAGE_NAME}:${VERSION}

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  ✓ 镜像推送成功！${NC}"
echo -e "${GREEN}========================================${NC}"
echo -e "镜像地址:"
echo -e "  ${ALIYUN_REGISTRY}/${ALIYUN_NAMESPACE}/${IMAGE_NAME}:latest"
echo -e "  ${ALIYUN_REGISTRY}/${ALIYUN_NAMESPACE}/${IMAGE_NAME}:${VERSION}"
echo ""
echo -e "运行命令:"
echo -e "  docker run -d \\"
echo -e "    --name uptime-kuma \\"
echo -e "    -p 3001:3001 \\"
echo -e "    -v uptime-kuma:/app/data \\"
echo -e "    ${ALIYUN_REGISTRY}/${ALIYUN_NAMESPACE}/${IMAGE_NAME}:latest"
echo ""
