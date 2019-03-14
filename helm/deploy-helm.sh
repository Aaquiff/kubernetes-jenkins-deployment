ADMIN_PASSWORD=$1

KUBECTL=`which kubectl`
HELM=`which helm`

echoBold "Initializing helm in cluster"
${KUBECTL} apply -f helm/rbac-config.yaml --username=admin --password=$ADMIN_PASSWORD
${HELM} init --service-account tiller --history-max 200 --upgrade