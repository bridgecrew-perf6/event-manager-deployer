zip -j producer.zip kafka-keda/kafka-producer/*

kubectl apply -f kafka-config.yaml
fission spec apply --wait --delete