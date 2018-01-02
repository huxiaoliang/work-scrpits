try service account to access the k8s in pod

We build app binary use docker multi-stage build feature
then create pod to run it inside k8s cluster

1. docker build -t in-cluster .

2. load(docker save/load) this image in-cluster:latest to the k8s 

3. kubectl run --rm -i demo --image=in-cluster --image-pull-policy=Never

Note:if you encounter the permission issue, type below command

kubectcreate clusterrolebinding myname-cluster-admin-binding --clusterrole=cluster-admin --user=system:serviceaccount:default:default
