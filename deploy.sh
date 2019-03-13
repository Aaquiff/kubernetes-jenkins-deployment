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

echoBold 'Creating jenkins namespace'
${KUBECTL} create namespace jenkins

${KUBECTL} config set-context $(kubectl config current-context) --namespace jenkins

echoBold "Creating WUM secret"
${KUBECTL} create secret generic wso2-credentials --from-literal=username=$WSO2_SUBSCRIPTION_USERNAME --from-literal=password=$WSO2_SUBSCRIPTION_PASSWORD
${KUBECTL} create secret generic registry-credentials-pod --from-literal=username=$REGISTRY_USERNAME --from-literal=password=$REGISTRY_PASSWORD
${KUBECTL} create secret docker-registry registry-credentials --docker-server=$REGISTRY_SERVER --docker-username=$REGISTRY_USERNAME --docker-password=$REGISTRY_PASSWORD --docker-email=$REGISTRY_EMAIL

echoBold "Initializing helm in cluster"
${KUBECTL} apply -f helm/rbac-config.yaml --username=admin --password=$ADMIN_PASSWORD
${HELM} init --service-account tiller --history-max 200 --upgrade