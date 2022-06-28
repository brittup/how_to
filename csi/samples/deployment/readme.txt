###Sample Deployment with Configs

kubectl apply -f  nginx-deployment.yaml  -n test

kubectl get deployments -n test

kubectl get rs -n test

kubectl get pods --show-labels -n test

kubectl edit deployment ngix-deployment -n test


