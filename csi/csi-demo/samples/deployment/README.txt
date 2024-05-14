###Sample Deployments with Configs




###non-resilent deployment 


kubectl apply -f pvc.yaml -n test

kubectl apply -f nginx-deployment.yaml -n test

kubectl get deployments -n test

kubectl get rs -n test

kubectl get pods --show-labels -n test

kubectl edit deployment ngix-deployment -n test




###resilent deployment - asssumes CSM resilency is setup


kubectl apply -f pvc-resilent.yaml -n test

kubectl apply -f nginx-deployment-resilent.yaml -n test

kubectl get deployments -n test

kubectl get rs -n test

kubectl get pods --show-labels -n test

kubectl edit deployment ngix-deployment -n test






