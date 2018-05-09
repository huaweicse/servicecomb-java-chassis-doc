## 概念阐述

系统通过配置中心来提供统一配置服务，配置中心是部署在云上的一个应用，用于配置的管理和下发，可为用户程序提供配置查询、存储等服务，统一管理配置。整个配置中心架构如下图所示：![](/start/统一配置服务.png)

配置中心的使用场景主要有两个：

1.微服务开发者通过Client SDK从配置中心获取配置，并作为自身运行环境的上下文。

2.运维管理人员通过UI portal维护配置中心各个应用的配置数据并下发到各个应用中。

我们开发者在本地开发的是Consumer/Provider应用，需要应用中配置好Config Center的访问路径和策略，配置定义在[microservices.yaml](#li4832148711727)中，详细的配置项参考表5-2。

## 配置说明

* microservices.yaml文件是微服务元数据配置文件，用于配置微服务的属性，微服务的常用属性定义如表1-1所示：

### 表1-1微服务属性定义表

| 配置项 | 参考/默认值 | 取值范围 | 是否必选 | 含义 | 注意 |
| :--- | :--- | :--- | :--- | :--- | :--- |
| APPLICATION\_ID | test |  | 是 | 服务ID |  |
| service\_description.name | MyService |  | 是 | 服务名称 |  |
| service\_description.version | 0.0.1 |  | 是 | 版本号 |  |
| service\_description.description |  |  | 否 | 服务描述 |  |
| service\_description.role |  | {FRONT,MIDDLE,BACK} | 否 | 微服务角色 | 描述微服务的层级信息，为front、middle或者back |
| service\_description.properties |  |  | 否 | key/value对 | 微服务properties，可为服务添加非通用的属性 |

### 表1-2微服务中配置中心配置项表

| 配置项 | 默认值 | 取值范围 | 是否必选 | 含义 | 注意 |
| :--- | :--- | :--- | :--- | :--- | :--- |
| cse.config.client.serverUri | [https://100.125.1.34:30103](https://100.125.1.34:30103) | schema://ip:port | 是 | 配置中心的地址，支持多个，用逗号分隔 | 若配置多个地址，则直接使用该配置项地址为config-center集群地址。 |
| cse.config.client.refreshPort | 30104 | 1024~65536 | 否 | 配置中心动态下发配置端口 |  |
| cse.config.client.refreshMode | 0 | {0,1} | 否 | 配置动态刷新模式 | 0为configcenter在发生变化时主动推送，1为client端周期拉取，其他值均为非法，不会去连配置中心。 |
| cse.config.client.refresh\_interval | 10000 | \[0,+∞\) | 否 | 配置动态刷新时间间隔 | refreshMode配置为1时，client端主动从配置中心拉取配置的周期，单位毫秒。 |
| cse.config.client.tenantName | default |  | 否 | 租户名 |  |
| service\_description.name | testclient |  | 否 | 应用名 |  |

## 示例代码

### **microservices.yaml文件：**

```yaml
APPLICATION_ID: test #服务ID
 service_description: 
   name: MyServer #应用名
   version: 1.0.0 #服务版本
   description: serverDescription #服务描述
   role: BACK #微服务角色
 cse: 
  #配置中心配置项
   config: 
     client: 
       serverUri: https://100.125.1.34:30103   #配置中心地址
       refreshPort: 30104 #配置中心动态下发端口
       refreshMode: 0 #配置动态刷新模式
       refresh_interval: 10000 #配置拉取周期，单位为毫秒
       tenantName: default#租户名
  #其他配置
```

### **业务代码如何使用动态配置：**

主动获取的方式：

```
DynamicPropertyFactory.getInstance().getStringProperty("configkey", "defaltval").get();
```

事件方式：

```
DynamicStringProperty ds = DynamicPropertyFactory.getInstance().getStringProperty("key", "defaultVal");
ds.addCallback(() -> {
    // do something!
});
```

使用Spring @Value注解的方式，可以直接使用

```
@Value("${cse.scope:hispace}")
private String scope;
```



