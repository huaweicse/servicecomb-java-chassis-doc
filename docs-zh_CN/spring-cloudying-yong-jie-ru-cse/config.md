Spring Cloud提供了多种机制发现服务实例：

1. 使用静态配置的地址列表；

2. 使用DiscoveryClient查找实例；

3. 使用Ribbon组件

4. 使用ZuulProxy进行消息转发

在本章节中，将介绍服务接入服务中心以后，如何动态发现实例。这个工作以“接入服务中心和配置中心”为基础。

本章节的涉及的代码参考：

* 原始Spring Cloud应用来源于官网

[https://spring.io/guides/gs/client-side-load-balancing/](https://spring.io/guides/gs/client-side-load-balancing/)

* 接入服务中心和配置中心示例

[https://github.com/huawei-microservice-demo/SpringCloudIntegration/tree/master/gs-client-side-load-balancing](https://github.com/huawei-microservice-demo/SpringCloudIntegration/tree/master/gs-client-side-load-balancing)

## 使用DiscoveryClient查找实例

使用DiscoveryClient查找实例的过程非常简单，只需要在客户端完成下面四步配置：

1.增加依赖关系

```
<dependency>
            <groupId>org.apache.servicecomb</groupId>
            <artifactId>spring-boot-starter-discovery</artifactId>
</dependency>
```

在代码中使用DiscoveryClient，包括几个步骤，详细可以参考UserApplication类

2.使用标签

@EnableDiscoveryClient

3.注入实例：

@Autowired

private DiscoveryClient discoveryClient;

4.获取实例：

List&lt;ServiceInstance&gt; instances =  discoveryClient.getInstances\("say-hello"\); // 其中“say-hello”为Provider微服务名称，对应microservice.yaml中service\_description.name

使用DiscoveryClient是非常灵活的方案，开发者可以自行定义负载均衡策略，进行实例隔离等。对于一些场景，开发者可能使用Ribbon简化这些策略的开发。

## 使用Ribbon组件

使用Ribbon的过程和DiscoveryClient非常类似，需要依赖spring-boot-starter-discovery。然后进行如下步骤：

* 使用标签

```
@RibbonClient(name = "say-hello", configuration = SayHelloConfiguration.class) // 其中“say-hello”为Provider微服务名称，对应microservice.yaml中service_description.name
```

* 注入实例

```
@LoadBalanced

@Bean

RestTemplate restTemplate(){

return new RestTemplate();

}
```

* 配置Ribbon，参考SayHelloConfiguration，下面自定义了ServerList

```
@Bean

ServerList<Server> ribbonServerList(

IClientConfig config) {

  ServiceCombServerList serverList = new ServiceCombServerList();

  serverList.initWithNiwsConfig(config);

  return serverList;

}
```

* 发送请求

```
restTemplate.getForObject("http://say-hello/greeting", String.class);
```

Ribbon对于快速开发提供了很多便利，但是有些特殊业务场景则需要用户自行完成，比如Ribbon无法动态知道服务端是SSL还是非SSL，需要在代码里面指定schema是http还是https。

## 使用ZuulProxy进行消息转发

使用Spring Cloud，一个微服务很容易扮演Proxy的角色，这个是通过ZuulProxy实现的。在代码中使用ZuulProxy也是非常简单的。依赖spring-boot-starter-discovery后做如下配置：

* 使用标签

```
@EnableZuulProx
```

* 在Application.yml中定义转发规则

```
zuul:
  routes:
    api:
      serviceId: say-hello
```

* 发送请求，user可以作为一个网关，直接转发请求到say-hello服务。

[http://localhost:8888/api/greeting](http://localhost:8888/api/greeting)

