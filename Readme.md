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