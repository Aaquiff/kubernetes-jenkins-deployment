#!/bin/bash

# ------------------------------------------------------------------------
# Copyright 2017 WSO2, Inc. (http://wso2.com)
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License
# ------------------------------------------------------------------------

set -e

ECHO=`which echo`
KUBECTL=`which kubectl`
HELM=`which helm`

# methods
function echoBold () {
    echo -e $'\e[1m'"${1}"$'\e[0m'
}

function usage () {
    echoBold "This script automates the installation of Jenkins on a kubernetes cluster\n"
    echoBold "Allowed arguments:\n"
    echoBold "-h | --help"
    echoBold "--wu | --wso2-username\t\tYour WSO2 username"
    echoBold "--wp | --wso2-password\t\tYour WSO2 password"
    echoBold "--cap | --cluster-admin-password\tKubernetes cluster admin password\n\n"
}

ADMIN_PASSWORD=$1
WSO2_SUBSCRIPTION_USERNAME=$2
WSO2_SUBSCRIPTION_PASSWORD=$3
REGISTRY_SERVER=$4
REGISTRY_USERNAME=$5
REGISTRY_PASSWORD=$6
REGISTRY_EMAIL=$7

# # capture named arguments
# while [ "$1" != "" ]; do
#     PARAM=`echo $1 | awk -F= '{print $1}'`
#     VALUE=`echo $1 | awk -F= '{print $2}'`

#     case ${PARAM} in
#         -h | --help)
#             usage
#             exit 1
#             ;;
#         --wu | --wso2-username)
#             WSO2_SUBSCRIPTION_USERNAME=${VALUE}
#             ;;
#         --wp | --wso2-password)
#             WSO2_SUBSCRIPTION_PASSWORD=${VALUE}
#             ;;
#         --cap | --cluster-admin-password)
#             ADMIN_PASSWORD=${VALUE}
#             ;;
#         *)
#             echoBold "ERROR: unknown parameter \"${PARAM}\""
#             usage
#             exit 1
#             ;;
#     esac
#     shift
# done

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

echoBold "Creating WUM secret"
${KUBECTL} create secret generic wso2-credentials --from-literal=username=$WSO2_SUBSCRIPTION_USERNAME --from-literal=password=$WSO2_SUBSCRIPTION_PASSWORD
${KUBECTL} create secret generic registry-credentials-pod --from-literal=username=$REGISTRY_USERNAME --from-literal=password=$REGISTRY_PASSWORD
${KUBECTL} create secret docker-registry registry-credentials --docker-server=$REGISTRY_SERVER --docker-username=$REGISTRY_USERNAME --docker-password=$REGISTRY_PASSWORD --docker-email=$REGISTRY_EMAIL

${KUBECTL} apply -f jenkins/roles.yaml --username=admin --password=$ADMIN_PASSWORD
${KUBECTL} create configmap jenkins-casc-conf --from-file=jenkins/casc_configs/ --dry-run -o yaml | ${KUBECTL} apply -f -
${KUBECTL} create configmap jenkins-init-script --from-file jenkins/init.groovy --dry-run -o yaml | ${KUBECTL} apply -f -

${KUBECTL} create configmap prod-config-conf --from-file jenkins/prod-config/ --dry-run -o yaml | ${KUBECTL} apply -f -

${KUBECTL} apply -f jenkins/k8s/
${KUBECTL} rollout status deployment/jenkins

echoBold "Initializing helm in cluster"
${KUBECTL} apply -f helm/rbac-config.yaml --username=admin --password=$ADMIN_PASSWORD
${HELM} init --service-account tiller --history-max 200 --upgrade