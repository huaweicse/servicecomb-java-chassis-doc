CSE服务中心提供了服务注册、发现等功能。使用CSE服务中心，还可以使用相关的配套工具，查看服务目录、服务实例信息，以及管控服务黑白名单等。开发者需要简单的几个步骤，就可以完成Spring Cloud应用接入服务中心。

本章节的涉及的代码参考：

* 原始Spring Cloud应用来源于官网：

[https://spring.io/guides/gs/rest-service/](https://spring.io/guides/gs/rest-service/)

* 接入服务中心和配置中心示例：

[https://github.com/huawei-microservice-demo/SpringCloudIntegration/tree/master/gs-rest-service](https://github.com/huawei-microservice-demo/SpringCloudIntegration/tree/master/gs-rest-service)

## 配置依赖关系

通过配置依赖关系，可以启用服务中心客户端连接功能，将Spring Cloud应用作为一个CSE的微服务注册到服务中心。

* 建议开发者在pom.xml中引入依赖的dependencyManagement，以便更好的管理使用的三方件，防止冲突。

```
    <dependencyManagement>
        <dependencies>
            <dependency>
                <groupId>com.huawei.paas.cse</groupId>
                <artifactId>cse-dependency</artifactId>
                <version>2.3.17</version>
                <type>pom</type>
                <scope>import</scope>
            </dependency>
        </dependencies>
    </dependencyManagement>
```

* 增加依赖关系

除了引用spring-boot-starter-registry和spring-boot-starter-configuration之外，还引用了foundation-auth包，这个包主要完成和CSE服务之间的认证。这个包默认依赖log4j，由于Spring Cloud默认使用logback作为日志记录器，需要排除掉对于log4j的引用。

```
        <dependency>
            <groupId>org.apache.servicecomb</groupId>
            <artifactId>spring-boot-starter-registry</artifactId>
        </dependency>
        <dependency>
            <groupId>org.apache.servicecomb</groupId>
            <artifactId>spring-boot-starter-configuration</artifactId>
        </dependency>
        <dependency>
            <groupId>com.huawei.paas.cse</groupId>
            <artifactId>foundation-auth</artifactId>
            <exclusions>
                <exclusion>
                    <groupId>org.slf4j</groupId>
                    <artifactId>slf4j-log4j12</artifactId>
                </exclusion>
            </exclusions>
        </dependency>
```

## 增加微服务信息描述和查看效果

通过以上的步骤，就完成了相关的开发工作。现在我们需要将应用启动起来，并查看效果。配置文件中，指定了应用ID，微服务名称等基本信息，以及服务中心和配置中心的地址。开发者需要首先从华为云获取到AK/SK认证信息，替换配置文件里面的内容。这样开发者的应用就可以启动运行了。

```
cse-config-order: 100
APPLICATION_ID: spring-cloud-app
service_description:
  name: spring-cloud-demo
  version: 0.0.1
cse:
  service:
    registry:
      address: https://cse.cn-north-1.myhwclouds.com:443
      instance:
        watch: false
  config:
    client:
      serverUri: https://cse.cn-north-1.myhwclouds.com:443
      refreshMode: 1
      refresh_interval: 15000

  credentials:
    accessKey: your access key in CSE
    secretKey: your secret key in CSE
    akskCustomCipher: default
```

通过运行Application，并登陆华为云CSE环境[https://console.huaweicloud.com/cse](https://console.huaweicloud.com/cse。)进入“微服务管理”-“服务目录菜单”，可以看到Spring Cloud注册的服务实例信息。

![](/assets/spring-cloud-integration-002.png)

为了演示动态配置，GreetingController增加如下代码。这个代码片段通过@Value增加了一个配置项来注入故障。

```
@Value(value="${spring.cloud.inject.fault:null}")
private String fault;

@RequestMapping("/greeting")
public Greeting greeting(@RequestParam(value="name", defaultValue="World") String name) {
//        String fault = 
// DynamicPropertyFactory.getInstance().getStringProperty("spring.cloud.inject.fault", null).get();
      if(fault != null) {
          return new Greeting(counter.incrementAndGet(),
              String.format(template, fault));
      }
      return new Greeting(counter.incrementAndGet(),
                          String.format(template, name));
  }
```

点击“微服务列表”下的微服务名称进入微服务基本信息页面，切换至“动态配置”，增加如下配置项：

![](/assets/spring-cloud-integration-003.png)

请求：[http://localhost:8080/greeting?name=world](http://localhost:8080/greeting?name=world)    输出结果是动态配置的信息：hello faultValue。除了使用@Value获取动态配置，开发者还可以使用DynamicPropertyFactory接口来读取动态配置。需要注意@Value和DynamicPropertyFactory的差别：@Value是Spring机制，动态配置更新的时候，必须重启才能够生效，运行时不会生效。DynamicPropertyFactory读取的值在运行时即可生效。Hystrix、Ribbon等组件内部的动态配置都是基于DynamicPropertyFactory的，因此Spring Cloud开发者如果使用这些组件，可以通过配置中心下发配置来管理Hystrix、Ribbon等组件。

说明：8080端口为SpringBoot定义的默认应用监听端口，如需修改请在src\main\resources下新增application.yaml，文件如下

```
server:
  port: 8090 # 自定义端口
```



