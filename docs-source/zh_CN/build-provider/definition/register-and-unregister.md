## 场景描述

当微服务启动时，需要向服务中心注册微服务信息和实例信息；关闭时，需要向服务中心注销实例信息。ServiceComb允许用户在项目不集成框架的情况下，手动完成这些操作。

## 涉及API

* `org.apache.servicecomb.config.ConfigUtil`：配置加载工具类
* `com.huawei.paas.cse.adapter.spingmvc.RegistryInitializer`：服务注册工具类
* `org.apache.servicecomb.serviceregistry.client.ServiceRegistryClient`：服务中心客户端

## 配置说明

### 服务注册

服务注册主要可以分为以下几个步骤：  
1. 初始化配置  
2. 初始化服务中心连接  
3. 注册微服务信息  
4. 注册实例信息

示例代码如下：

```java
public static void main(String[] args) throws Exception {
    // 1. 初始化配置
    ConfigUtil.installDynamicConfig();
    // 2. 初始化服务中心连接
    RegistryInitializer.initRegistry();

    ServiceRegistryClient client = RegistryInitializer.getServiceRegistryClient();
    Microservice owner = RegistryInitializer.getSelfMicroservice();
    MicroserviceInstance ownerInst = RegistryInitializer.getSelfMicroserviceInstance();

    // 查询微服务服务是否已被注册
    String serviceId = client.getMicroserviceId(owner.getAppId(),
            owner.getServiceName(),
            owner.getVersion());
    if (serviceId != null && !serviceId.isEmpty()) {
        System.out.println("service already exists.");
    } else {
        // 如果没有，则注册此微服务
        serviceId = client.registerMicroservice(owner);
        System.out.println("microservice id=" + serviceId);
    }
    owner.setServiceId(serviceId);

    MicroserviceInstance instance = new MicroserviceInstance();
    instance.setInstanceId("");
    instance.setEndpoints(ownerInst.getEndpoints());
    instance.setHealthCheck(ownerInst.getHealthCheck());
    instance.setHostName(ownerInst.getHostName());
    instance.setServiceId(owner.getServiceId());
    instance.setStage(ownerInst.getStage());
    instance.setStatus(ownerInst.getStatus());

    // 注册实例信息
    serviceId = client.registerMicroserviceInstance(instance);
    System.out.println("registerMicroserviceInstance serviceId=" + serviceId);
    instance.setInstanceId(serviceId);

    // other code omitted
}
```

### 服务注销

`RegistryInitializer`中提供了注销服务的方法`unregsiterInstance`，用户调用此方法即可注销实例：

```java
/**
 * 注销本服务
 * @return 是否成功
 */
public static boolean unregsiterInstance();
```



