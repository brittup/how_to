# Add nfs mount to isilon /ifs/k8 directly


kubectl create -f nfs-pv.yaml -n test
kubectl get pv -n test
kubectl describe pv nfs -n test


kubectl create -f nfs-pvc.yaml -n test
kubectl get pvc -n test
kubectl describe pvc nfs -n test

kubectl create -f nfs-nginx.yaml -n test
kubectl get pods -n test
kubectl describe pod nginx-pv-pod -n test



kubectl exec nginx-pv-pod -i -t -n test -- bash
ls -al /usr/share/nginx/html/
cd /usr/share/nginx/html/
touch test1.txt
ls -al


kubectl delete pod nginx-pv-pod 