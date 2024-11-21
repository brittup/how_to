###Sample Deployments with Configs

create files and copy contents, then create


###non-resilent deployment 
touch pvc-deployment-non-resilent.yaml
touch nginx-deployment-non-resilent.yaml


kubectl apply -f pvc-deployment-non-resilent.yaml -n test

kubectl apply -f nginx-deployment-non-resilent.yaml -n test

kubectl get deployments -n test

kubectl get rs -n test

kubectl get pods --show-labels -n test

kubectl edit deployment nginx-deployment-non-resilent.yaml -n test




###resilent deployment - asssumes CSM resilency is setup
touch pvc-deployment-resilent.yaml
touch nginx-deployment-resilent.yaml


kubectl apply -f pvc-resilent.yaml -n test

kubectl apply -f nginx-deployment-resilent.yaml -n test

kubectl get deployments -n test

kubectl get rs -n test

kubectl get pods --show-labels -n test

kubectl edit deployment ngix-deployment -n test










