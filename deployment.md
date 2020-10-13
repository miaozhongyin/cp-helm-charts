#kafka 基于k8s容器化部署方案

-----
###使用说明

- 当前kafka k8s容器化部署方案是基于【confluent】提供的cp-helm-charts安装包，内部包含zookeeper，kafka 组件，如果k8s集群中已经包含了zookeeper组件，
可以在./values.yaml配置文件中关闭zookeeper服务，并在charts/cp-kafka/values.yaml 文件中配置cp-zookeeper.url 地址。
- 安装部署前请根据环境需求配置pv,sc 目录中的相关参数。
- kafka 部署headless service 默认访问地址为 cp-helm-charts-cp-kafka-headless:9092

-----
###测试环境:
k8s 部署环境：10.8.4.13，10.8.4.43，10.8.4.73，

----

###测试步骤如下：

1. 安装helm3. 
2. 下载 [​https://github.com/miaozhongyin/cp-helm-charts](https://github.com/miaozhongyin/cp-helm-charts) 到安装kubectl 的节点（10.8.4.13）
3. 在3台运行环境中下载所需docker 镜像
-  `docker pull confluentinc/cp-zookeeper:5.4.0 `
-  `docker pull confluentinc/cp-enterprise-kafka:5.4.0` 
-  `docker pull confluentinc/cp-enterprise-control-center:5.2.0` 
4. 预先创建pv 和 storageClass (采用local pv类型需要提前创建),在项目pv和sc 目录中.
-  `kubectl create -f pv/data-zookeeper-pv0.yaml` 
-  `kubectl create -f pv/data-zookeeper-pv1.yaml` 
-  `kubectl create -f pv/data-zookeeper-pv2.yaml` 
-  `kubectl create -f pv/log-zookeeper-pv0.yaml` 
-  `kubectl create -f pv/log-zookeeper-pv1.yaml` 
-  `kubectl create -f pv/log-zookeeper-pv2.yaml` 
-  `kubectl create -f pv/data-kafka-pv0.yaml` 
-  `kubectl create -f pv/data-kafka-pv1.yaml` 
-  `kubectl create -f pv/data-kafka-pv2.yaml` 
-  `kubectl create -f sc/data-kafka-sc.yaml` 
-  `kubectl create -f sc/data-zookeeper-sc.yaml` 
-  `kubectl create -f sc/log-zookeeper-sc.yaml` 
5. 在3 台节点上创建 pv 配置文件中指定的目录。
-  `mkdir -p /mnt/pv/zookeeper/log` 
-  `mkdir -p /mnt/pv/zookeeper/data` 
-  `mkdir -p /mnt/pv/kafka/data` 
6. 创建namespace
-  `kubectl create namespace miaozy` 
7. 在cp-helm-charts 项目中打包charts
-  `helm package cp-helm-charts` 
8. 安装 cp-helm-charts ，开始部署zookeeper,kafka 容器化。
-  `helm install  cp-helm-charts --namespace miaozy ./cp-helm-charts-0.4.0.tgz ` 
9. 进入k8s 管理界面查看部署情况。

----

##容器测试。

1. 部署zk-client 容器。
-  `kubectl apply -f client/zk-client.yaml -n miaozy ` 
-  `kubectl exec -it zookeeper-client  /bin/bash -n miaozy` 
-  `zookeeper-shell cp-helm-charts-cp-zookeeper:2181` 
-  `ls /brokers/topics` 
1. 部署kafka-client 容器
-  `kubectl apply -f client/kafka-client.yaml -n miaozy ` 
-  `kubectl exec -it kafka-client /bin/bash -n miaozy` 
- `kafka-topics --zookeeper cp-helm-charts-cp-zookeeper-headless:2181 --topic cp-helm-charts-topic --create --partitions 1 --replication-factor 1 --if-not-exists`
-  `MESSAGE=" date -u ";echo "$MESSAGE" | kafka-console-producer --broker-list cp-helm-charts-cp-kafka-headless:9092 --topic cp-helm-charts-topic` 
- `kafka-console-consumer --bootstrap-server cp-helm-charts-cp-kafka-headless:9092 --topic cp-helm-charts-topic --from-beginning --timeout-ms 2000 --max-messages 1 | grep "$MESSAGE"`
