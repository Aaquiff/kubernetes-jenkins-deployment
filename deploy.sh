#!/usr/bin/env bash

CLUSTER_ADMIN_PASSWORD=$1
KUBECTL=`which kubectl`

# methods
function echoBold () {
    echo -e $'\e[1m'"${1}"$'\e[0m'
}

function usage () {
    echoBold "This script automates the installation of Jenkins on a kubernetes cluster"
    echoBold "Usage: $0 {CLUSTER_ADMIN_PASSWORD}"
}

if [ "$CLUSTER_ADMIN_PASSWORD" = "" ]
then
    echoBold "Missing cluster admin password"
    usage
    exit 1
fi

echoBold 'Creating namespaces'
kubectl create namespace registry
kubectl create namespace jenkins

# Deploy registry
echoBold 'Deploying Registry'
${KUBECTL} config set-context $(kubectl config current-context) --namespace registry
${KUBECTL} apply -f registry/
${KUBECTL} rollout status deployments/registry

echoBold 'Deploying Jenkins'
# Deploy jenkins
${KUBECTL} config set-context $(kubectl config current-context) --namespace jenkins
${KUBECTL} apply -f jenkins/roles.yaml --username=admin --password=$CLUSTER_ADMIN_PASSWORD
${KUBECTL} apply -f jenkins/k8s/
${KUBECTL} rollout status deployment/jenkins

echoBold 'Waiting for jenkins to start...'
sleep 30

echo "Jenkins initial admin password:"
${KUBECTL} exec -it $(${KUBECTL} get pods --selector=app=jenkins --output=jsonpath={.items..metadata.name}) cat /var/jenkins_home/secrets/initialAdminPassword