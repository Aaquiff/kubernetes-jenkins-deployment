#!/usr/bin/env bash

KUBECTL=`which kubectl`

${KUBECTL} config set-context $(kubectl config current-context) --namespace registry
${KUBECTL} delete -f registry/deployment.yaml
${KUBECTL} delete -f registry/service.yaml

${KUBECTL} config set-context $(kubectl config current-context) --namespace jenkins
${KUBECTL} delete -f jenkins/k8s/deployment.yaml
${KUBECTL} delete -f jenkins/k8s/service.yaml

${KUBECTL} delete namespace jenkins
${KUBECTL} delete namespace registry

sleep 10