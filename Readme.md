# Jenkins Deployment on Kubernetes

Use the `jenkins` helm chart to deploy a jenkins instance that could handle the CI/CD operations for WSO2 products.

```
.
├── jenkins
│   └── jenkins.yaml
├── jenkins-docker
│   ├── Dockerfile
│   └── plugins.txt
├── helm
│   ├── deploy-helm.sh
|   └── rbac-config.yaml
├─── README.md
```

* `jenkins` folder contains the helm chart for the jenkins server including the registry chart.
* `jenkins-docker` contains resources to build the docker image if changes are required.
* `helm` directory contains the script and the manifest for deploying the helm RBAC role. 

## Considerations

* Nodes in the cluster should have docker installed because the jenkins pod will use the docker installed on the node it's running on.

## Troubleshooting

#### Error: failed to create resource: namespaces "wso2" not found or Error: UPGRADE FAILED: failed to create resource: namespaces "wso2" not found
Check if there is a failed helm deployment for the chart in the target environment. If there is an existing deployment, delete the deployment.
