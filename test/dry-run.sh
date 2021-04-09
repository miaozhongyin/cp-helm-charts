### kubectl cmd
kubectl get pod -n  logkeeper-kafka-test
kubectl logs -f logkeeper-kafka-dev-0 logkeeper-kafka-broker -n logkeeper-kafka-test
kubectl delete pod logkeeper-kafka-dev-0 -n  logkeeper-kafka-test
kubectl describe pv logkeeper-kafka-data-pv0
kubectl exec -it logkeeper-kafka-dev-0 logkeeper-kafka-broker -n logkeeper-kafka-test /bin/bash

### helm cmd
helm list --all-namespaces
helm upgrade  logkeeper-kafka-dev --namespace logkeeper-kafka-test ./logkeeper-kafka-charts
helm install  logkeeper-kafka-dev --namespace logkeeper-kafka-test ./logkeeper-kafka-charts
helm uninstall  logkeeper-kafka-dev --namespace logkeeper-kafka-test

### docker cmd
docker tag confluentinc/cp-kafka:6.0.1   harbor.k8s/agree/ada/logkeeper-kafka:3.4.0
docker push harbor.k8s/agree/ada/logkeeper-kafka:3.4.0
