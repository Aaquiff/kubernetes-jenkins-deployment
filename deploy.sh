#!/usr/bin/env bash

# Deploy registry
kubectl apply -f registry/deployment.yaml
kubectl rollout status deployments/registry

# Build and run proxy container for registry
docker build -t socat-registry -f socat/Dockerfile socat
docker stop socat-registry; docker rm socat-registry
docker run -d -e "REG_IP=`minikube ip`" -e "REG_PORT=30400" --name socat-registry -p 30400:5000 socat-registry
sleep 10

# Build and push latest version of jenkins to local registry
docker build -t 127.0.0.1:30400/jenkins:latest -f applications/Dockerfile applications/jenkins
docker push 127.0.0.1:30400/jenkins:latest

docker stop socat-registry

# Deploy jenkins
kubectl apply -f jenkins/deployment.yaml
kubectl rollout status deployment/jenkins
minikube service jenkins