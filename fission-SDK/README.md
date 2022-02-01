## Install minikube
https://minikube.sigs.k8s.io/docs/start/
```shell
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube
```
## Run mini cluster
https://minikube.sigs.k8s.io/docs/drivers/
https://minikube.sigs.k8s.io/docs/drivers/docker/#rootless-docker
```shell
dockerd-rootless-setuptool.sh install -f
docker context use rootless

minikube start --driver=docker --container-runtime=containerd
```

## Install fission
https://fission.io/docs/installation/   
https://fission.io/docs/installation/advanced-setup/
```shell
kubectl create -k "github.com/fission/fission/crds/v1?ref=v1.15.0"
export FISSION_NAMESPACE="fission"
kubectl create namespace $FISSION_NAMESPACE
kubectl config set-context --current --namespace=$FISSION_NAMESPACE
kubectl apply -f https://github.com/fission/fission/releases/download/v1.15.0/fission-all-v1.15.0-minikube.yaml
```

## Install Fission CLI
https://fission.io/docs/installation/#install-fission-cli
```shell
curl -Lo fission https://github.com/fission/fission/releases/download/v1.15.0/fission-v1.15.0-linux-amd64 \
    && chmod +x fission && sudo mv fission /usr/local/bin/
```

## Run Fission example
https://fission.io/docs/installation/#run-an-example
```shell
# Add the stock NodeJS env to your Fission deployment
fission env create --name nodejs --image fission/node-env

# A javascript function that prints "hello world"
curl -LO https://raw.githubusercontent.com/fission/examples/master/nodejs/hello.js

# Upload your function code to fission
fission function create --name hello-js --env nodejs --code hello.js

# Test your function.  This takes about 100msec the first time.
fission function test --name hello-js
Hello, world!
```
## SET Fission Router
```shell
export FISSION_ROUTER=$(minikube ip):$(kubectl -n fission get svc router -o jsonpath='{...nodePort}')
```

## Install KEDA
https://keda.sh/docs/2.5/deploy/    
https://github.com/kedacore/charts
```shell
helm repo add kedacore https://kedacore.github.io/charts

helm repo update

#Install keda Helm chart
kubectl create namespace keda
helm install keda kedacore/keda --namespace keda
```

## Setup KAFKA
https://strimzi.io/quickstarts/
```shell
kubectl create namespace kafka
kubectl create -f 'https://strimzi.io/install/latest?namespace=kafka' -n kafka
kubectl apply -f https://strimzi.io/examples/latest/kafka/kafka-persistent-single.yaml -n kafka
 
```
## Bind trigger
```shell
TRIGGER_NAME=kafkatest
FUNCTION_NAME=hello-js
KAFKA_BOOTSTRAP_SERVER=192.168.88.207:29092
fission mqt create --name ${TRIGGER_NAME} \
  --function ${FUNCTION_NAME} \
  --mqtype kafka \
  --mqtkind keda \
  --topic request-topic \
  --resptopic response-topic \
  --errortopic error-topic \
  --maxretries 3 \
  --metadata bootstrapServers=${KAFKA_BOOTSTRAP_SERVER} \
  --metadata topic=request-topic  \
  --metadata consumerGroup=my-group \
  --cooldownperiod=30 \
  --pollinginterval=5 \
  --secret keda-kafka-secrets
```

## Building custom node images
```shell
git clone git@github.com:dasmeta/fission-environments.git 
cd fission-environments/nodejs

# nodejs base docker image tag
NODE_BASE_IMG_TAG=12.22.8-stretch-slim
# logged in dockerhub user username
DOCKERHUB_USER=8723rbycalny8

docker build -t $DOCKERHUB_USER/node-env --build-arg NODE_BASE_IMG=$NODE_BASE_IMG_TAG -f Dockerfile . 
docker push $DOCKERHUB_USER/node-env

cd builder && docker build -t $DOCKERHUB_USER/node-builder --build-arg NODE_BASE_IMG=$NODE_BASE_IMG_TAG -f Dockerfile .
docker push $DOCKERHUB_USER/node-builder
```

## View full namespace log
```shell
./log-fission-function.sh fission-function
```
## Known Restrictions
- `Package.Name: Invalid value: attendance-overtime--handle-attendance-overtimes-on-group-remove: [must be no more than 63 characters]`
- `Function.Name: Invalid value: statistics--handle-partner-school-statistic-on-group-student-add: [must be no more than 63 characters]`