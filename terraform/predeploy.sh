#!/bin/bash
GREEN='\033[0;32m'
NC='\033[0m' # No Color
docker login --username liannus --password $TF_VAR_docker_hub_password

kubectl apply --validate=false -f https://github.com/jetstack/cert-manager/releases/download/v1.0.3/cert-manager.crds.yaml

echo -e "${GREEN}WOLKSTACK: Building dockerfiles...${NC}"
docker build ../apps/frontend -t liannus/wolkstack:frontend -f ../apps/frontend/Dockerfile
docker build ../apps/backend-t liannus/wolkstack:backend -f  ../apps/backend/Dockerfile
docker build ../apps/database -t liannus/wolkstack:database -f  ../apps/database/Dockerfile

echo -e "${GREEN}WOLKSTACK: Tagging dockerfiles...${NC}"
docker tag liannus/wolkstack:frontend liannus/wolkstack:frontend
docker tag liannus/wolkstack:backend liannus/wolkstack:backend
docker tag liannus/wolkstack:database liannus/wolkstack:database

echo -e "${green}WOLKSTACK: Pushing containers...${NC}"
docker push liannus/wolkstack:frontend
docker push liannus/wolkstack:backend
docker push liannus/wolkstack:database

echo -e "${green}WOLKSTACK: SUCCESS - App container pushed!...${NC}"