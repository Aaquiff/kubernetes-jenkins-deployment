#!/usr/bin/env bash

CLUSTER_ADMIN_PASSWORD=$1
WSO2_USERNAME=$2
WSO2_PASSWORD=$3
KUBECTL=`which kubectl`

# methods
function echoBold () {
    echo -e $'\e[1m'"${1}"$'\e[0m'
}

function usage () {
    echoBold "This script automates the installation of Jenkins on a kubernetes cluster"
    echoBold "Usage: $0 CLUSTER_ADMIN_PASSWORD WUM_USERNAME WUM_PASSWORD"
}

if [ "$3" = "" ]
then
    echoBold "Incorrect Usage!"
    usage
    exit 1
fi

echoBold 'Creating namespaces'
${KUBECTL} create namespace registry
${KUBECTL} create namespace jenkins

# Deploy registry
echoBold 'Deploying Registry'
${KUBECTL} config set-context $(kubectl config current-context) --namespace registry
${KUBECTL} apply -f registry/
${KUBECTL} rollout status deployments/registry

echoBold 'Deploying Jenkins'
# Deploy jenkins
${KUBECTL} config set-context $(kubectl config current-context) --namespace jenkins
${KUBECTL} apply -f jenkins/roles.yaml --username=admin --password=$CLUSTER_ADMIN_PASSWORD
${KUBECTL} create configmap jenkins-casc-conf --from-file=jenkins/casc_configs/
${KUBECTL} apply -f jenkins/k8s/
${KUBECTL} rollout status deployment/jenkins

echoBold 'Waiting for jenkins to start...'
sleep 30

echo "Jenkins initial admin password:"
${KUBECTL} exec -it $(${KUBECTL} get pods --selector=app=jenkins --output=jsonpath={.items..metadata.name}) cat /var/jenkins_home/secrets/initialAdminPassword

echoBold "Creating WUM secret"
kubectl create secret generic --from-literal=username=$WSO2_USERNAME --from-literal=password=$WSO2_PASSWORD

echoBold "Creating staging namespace, service-account and RBAC"
${KUBECTL} create namespace wso2-staging
${KUBECTL} config set-context $(kubectl config current-context) --namespace wso2-staging
${KUBECTL} create serviceaccount wso2svc-account -n wso2-staging
${KUBECTL} create --username=admin --password=$CLUSTER_ADMIN_PASSWORD -f wso2/rbac-staging.yaml

echoBold "Creating production namespace, service-account and RBAC"
${KUBECTL} create namespace wso2-prod
${KUBECTL} config set-context $(kubectl config current-context) --namespace wso2-prod
${KUBECTL} create serviceaccount wso2svc-account -n wso2-prod
${KUBECTL} create --username=admin --password=$CLUSTER_ADMIN_PASSWORD -f wso2/rbac-prod.yaml