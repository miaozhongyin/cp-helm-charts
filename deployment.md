#kafka 基于k8s容器化部署方案

-----
###使用说明

- 当前kafka k8s容器化部署方案是基于【confluent】提供的cp-helm-charts安装包，内部包含zookeeper，kafka 组件，如果k8s集群中已经包含了zookeeper组件，
需要在./values.yaml 文件中配置cp-zookeeper.url 地址，如果环境中没有部署zookeeper,可以使用安装包自带zookeeper,只需在./values.yaml配置文件中打开zookeeper服务，安装包会自动部署zookeeper组件。
- 如果部署环境中已有默认的sc,请在./values.yaml配置文件中给相应的组件指定默认的sc(参数为:dataDirStorageClass).如果环境中默认没有提供对应的sc,请根据环境需求配置pv,sc 目录中的相关参数,并创建相关资源。
- kafka 部署headless service 默认访问地址为 cp-helm-charts-cp-kafka-headless:9092
- 安装包使用helm3 安装，如需要安装请参考下载连接地址：https://github.com/helm/helm/releases

----

###kafka安装步骤如下：

1. 安装helm3 到部署节点. 
2. 解压cp-helm-charts 安装包到安装节点。
3. 如需修改kafka组件启动参数，请在./values.yaml中修改对应参数。
4. 在部署节点上下载所需docker 镜像
-  `docker pull confluentinc/cp-enterprise-kafka:5.4.0` 
5. 创建pv 和 storageClass (采用local pv类型需要提前创建),在项目pv和sc 目录中.已有默认sc,可忽略该步骤,只需在./values.yaml配置文件中给相应的组件指定默认的sc即可。
-  `kubectl create -f sc/kafka/kafka-data-sc.yaml`
-  `kubectl create -f pv/kafka/kafka-data-pv0.yaml` 
-  `kubectl create -f pv/kafka/kafka-data-pv1.yaml` 
-  `kubectl create -f pv/kafka/kafka-data-pv2.yaml`  
6. 在所有部署节点上创建 pv 配置文件中指定的目录,(如采用默认sc,请忽略该步骤,如已修改了kafka pv 中的存储路径path,请同步修改创建路径)。
-  `mkdir -p /mnt/pv/kafka/data` 
7. 创建namespace (这里的namespace 指定为kafka,如需创建其他namespace,请修改与之相关的pv中的namespace)
-  `kubectl create namespace kafka` 
8. 在cp-helm-charts 项目中打包charts
-  `helm package cp-helm-charts` 
9. 安装 cp-helm-charts ，开始部署kafka。
-  `helm install  cp-helm-charts-kafka --namespace kafka ./cp-helm-charts-0.4.0.tgz ` 
10. 进入k8s 管理界面或者用命令查看部署情况。

----

##kafka容器测试。

1. 部署kafka-client 容器
- `kubectl apply -f client/kafka/kafka-client.yaml -n kafka `  
- `kubectl exec -it kafka-client /bin/bash -n kafka` 
- `MESSAGE=" date -u ";echo "$MESSAGE" | kafka-console-producer --broker-list cp-helm-charts-kafka-cp-kafka-headless:9092 --topic cp-helm-charts-topic` 
- `kafka-console-consumer --bootstrap-server cp-helm-charts-kafka-cp-kafka-headless:9092 --topic cp-helm-charts-topic --from-beginning --timeout-ms 2000 --max-messages 1 | grep "$MESSAGE"`

-----
###zookeeper部署

1. 安装helm3 到部署节点. 
2. 解压cp-helm-charts 安装包到安装节点。
3. 如需修改zookeeper组件启动参数，请在./values.yaml中修改对应参数。
4. 在部署节点上下载所需docker 镜像
-  `docker pull confluentinc/cp-zookeeper:5.4.0 `
5. 创建pv 和 storageClass (采用local pv类型需要提前创建),在项目pv和sc 目录中.已有默认sc,可忽略该步骤,只需在./values.yaml配置文件中给相应的组件指定默认的sc即可。
-  `kubectl create -f sc/zookeeper/zookeeper-data-sc.yaml` 
-  `kubectl create -f sc/zookeeper/zookeeper-log-sc.yaml` 
-  `kubectl create -f pv/zookeeper/zookeeper-data-pv0.yaml` 
-  `kubectl create -f pv/zookeeper/zookeeper-data-pv1.yaml` 
-  `kubectl create -f pv/zookeeper/zookeeper-data-pv2.yaml` 
-  `kubectl create -f pv/zookeeper/zookeeper-log-pv0.yaml` 
-  `kubectl create -f pv/zookeeper/zookeeper-log-pv1.yaml` 
-  `kubectl create -f pv/zookeeper/zookeeper-log-pv2.yaml` 
6. 在部署节点上创建 pv 配置文件中指定的目录。
-  `mkdir -p /mnt/pv/zookeeper/log` 
-  `mkdir -p /mnt/pv/zookeeper/data` 
7. 创建namespace
-  `kubectl create namespace zookeeper` 
8. 在cp-helm-charts 项目中打包charts
-  `helm package cp-helm-charts` 
9. 安装 cp-helm-charts ，开始部署zookeeper,kafka 容器化。
-  `helm install  cp-helm-charts-zookeeper --namespace zookeeper ./cp-helm-charts-0.4.0.tgz ` 
10. 进入k8s 管理界面查看部署情况。


##容器测试。

1. 部署zk-client 容器。
-  `kubectl apply -f client/zookeeper/zk-client.yaml -n zookeeper` 
-  `kubectl exec -it zookeeper-client  /bin/bash -n zookeeper` 
-  `zookeeper-shell cp-helm-charts-zookeeper-cp-zookeeper-headless:2181` 
-  `ls /brokers/topics` 