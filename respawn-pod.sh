#!/usr/bin/env bash

POD_NAME=$(kubectl get pods --selector=app=jenkins --output=jsonpath={.items..metadata.name})

kubectl logs $POD_NAME
kubectl apply -f jenkins/deployment.yaml
kubectl delete pods/$POD_NAME
sleep 10

NEW_POD_NAME=$(kubectl get pods --selector=app=jenkins --output=jsonpath={.items..metadata.name})
kubectl exec -it $NEW_POD_NAME kubectl config view
kubectl exec -it $NEW_POD_NAME kubectl version