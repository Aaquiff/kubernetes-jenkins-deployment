# Jenkins Deployment on Kubernetes

Use the `jenkins` helm chart to deploy a jenkins instance that could handle the CI/CD operations for WSO2 products.

## Considerations

* Nodes in the cluster should have docker installed because the jenkins pod will use the docker installed on the node it's running on.