try service account to access the k8s out of pod

1.docker build -t out-cluster .

2.docker create --name extract-main out-cluster:latest

3.docker cp extract-main:/go/src/app ./app

4.scp app binary to the host which installed kubectl

5.clean: docker rm -f extract-main && docker rmi -f out-cluster:latest

