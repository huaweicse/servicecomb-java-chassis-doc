## 概念阐述

在一个长事务中，一个由两台服务器一起参与的事务，服务器A发起事务，服务器B参与事务，B的事务需要人工参与，所以处理时间可能很长。如果按照ACID的原则，要保持事务的隔离性、一致性，A发起事务使用到的事务资源将被锁定，不允许其他应用访问到事务过程中的中间结果，直到整个事务被提交或者回滚。这就造成事务A中的资源被长时间锁定，系统将不可用。

为了解决在事务运行过程中大颗粒度资源锁定的问题，业界提出一种新的事务模型，它是基于业务层面的事务定义。锁粒度完全由业务自己控制。它本质是一种补偿的思想。它把事务运行过程分成Try、Confirm/Cancel两个阶段。在每个阶段的逻辑由业务代码控制。这样就事务的锁粒度可以完全自由控制。业务可以在牺牲强隔离性的情况下，获取更高的性能。

## 场景描述

![](/start/TCC机制的数据.png)

## 开发示例

* **步骤 1**POM中引入TCC事务对应的依赖包：

```xml
<dependency>
  <groupId>com.huawei.paas.cse</groupId>
  <artifactId>cse-handler-tcc</artifactId>
</dependency>
```

* **步骤 2**在microservice.yaml中添加进处理链：

```yaml
cse:
 ......
 handler:
  chain:
   Provider:
    default: perf-stats,tcc-server
 ......
```

* **步骤 3**定义服务实现类

```java
@RpcSchema(schemaId = "helloworld")
public class TccHelloworldImpl implements ITccHelloworld {
private static final Logger LOGGER = LoggerFactory.getLogger(TccHelloServiceImpl.class);
@Override
@TccTransaction(confirmMethod = "confirm", cancelMethod = "cancel")
private String sayHello(String name) {
　LOGGER.info("Try say hello from client, {}", name);
　return "Hello, " + name;
}
private String confirm(String name) {
　LOGGER.info("Confirm say hello from client, {}", name);
　return null;
}
private String cancel(String name) {
　LOGGER.info("Cancel say hello from client, {}", name);
　return null;
}
}
```

在支持TCC事务的方法上打上@TccTransaction标注，并注明confirmMethod和cancelMethod方法。confirmMethod和cancelMethod的参数和返回值必须和服务提供函数相同。如果Try正常执行，confirm方法也会被执行。如果Try抛出异常，则cancel会被执行。

* 如果不使用标注的方式发布服务，那么需要在实现类上面打上@Component标注。

* TCC事务对业务逻辑定义需要有一定要求，TCC操作应该支持幂等性原则，否则容易产生过度补偿等问题。

* TCC支持运行在微服务多实例中，其原理是将事务数据统一存储到数据库中，TCC组件提供统一的事务存储接口，以便开发对接不同的数据库，只需要继承实现com.huawei.paas.cse.tcc.repository.CachableTransactionRepository类即可完成多实例TCC支持；也可参考com.huawei.paas.cse.tcc.repository包中简单的数据库存储类实现，已简单实现了Jdbc/redis/ZooKeeper的对接。

* yaml文件中bizkeeper和tcc-server配置先后顺序会引起前台仪表盘不同的计数方式。若将tcc-server配置在bizkeeper前，仪表盘中显示server端一次调用，反之仪表盘显示两次调用，因为bizkeeper的计数在tcc-sever的打点前则会有2次restful接口调用。

## 配置说明

TCC配置在microservice.yaml文件中，相关配置项如下。

表1-1QPS流控配置项说明

| 配置项 | 默认值 | 取值范围 | 是否必选 | 含义 |
| :--- | :--- | :--- | :--- | :--- |
| cse.tcc.transaction.repository | com.huawei.paas.cse.tcc.repository.FileSystemTransactionRepository | true/false | 是 | 事务存储仓库 |
| cse.tcc.transaction.repository.file.path | tcc | - | 是 | 使用文件系统存储事务时，指定文件存储根路径，默认在当前目录的tcc文件夹下 |
| cse.tcc.transaction.recover | true | true/false | 是 | 是否启动恢复机制 |



