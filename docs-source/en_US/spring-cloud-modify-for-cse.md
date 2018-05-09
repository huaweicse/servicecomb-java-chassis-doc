本章节通过一个实际的案例，说明如何将Spring Cloud应用经过少量的改造，接入CSE。



* 原始Spring Cloud应用下载地址：

[https://registry.cn-north-1.huaweicloud.com/swr/v2/domains/hwcse/namespaces/hwcse/repositories/default/packages/springcloud-demo/versions/0.0.1/file\_paths/springcloud-sample.zip](https://registry.cn-north-1.huaweicloud.com/swr/v2/domains/hwcse/namespaces/hwcse/repositories/default/packages/springcloud-demo/versions/0.0.1/file_paths/springcloud-sample.zip)

## 步骤一：配置依赖关系

* 建议开发者在项目父pom.xml新增dependencyManagement，以便更好的管理使用的三方件，防止冲突。

```
    <dependencyManagement>
        <dependencies>
            <dependency>
                <groupId>com.huawei.paas.cse</groupId>
                <artifactId>cse-dependency</artifactId>
                <version>2.3.12</version>
                <type>pom</type>
                <scope>import</scope>
            </dependency>
        </dependencies>
    </dependencyManagement>
```

* 增加依赖关系

在springcloud-provider和springcloud-consumer项目pom.xml中，引用下述依赖：  
spring-boot-starter-registry、spring-boot-starter-configuration用于注册和配置；  
spring-boot-starter-discovery用于使用DiscoveryClient查找实例；  
foundation-auth用于与CSE服务之间的认证，该包默认依赖log4j，由于Spring Cloud默认使用logback作为日志记录器，需要排除掉对于log4j的引用。

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
            <groupId>org.apache.servicecomb</groupId>
            <artifactId>spring-boot-starter-discovery</artifactId>
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

* 删除eureka依赖

父pom.xml中删除对spring-cloud-starter-eureka-server的依赖；  
springcloud-provider和springcloud-consumer项目pom.xml中删除对spring-cloud-starter-eureka的依赖

## 步骤二：增加微服务信息描述

通过以上的步骤，就完成了相关的开发工作。现在我们需要将应用启动起来，并查看效果。在这个步骤之前，需要先在src/main/resources下增加微服务描述文件microservice.yaml。 配置文件指定了应用ID，微服务名称等基本信息，以及服务中心和配置中心的地址。开发者需要首先从华为云获取到AK/SK认证信息，替换配置文件里面的内容。这样开发者的应用就可以启动运行了。

* provider端

  ```yaml
  cse-config-order: 100
  APPLICATION_ID: spring-cloud-sample
  service_description:
    name: helloprovider
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
    rest:
      address: 0.0.0.0:7111 # 7111端口与src/main/resources/application.yml中server.port保持一致
    credentials:
      accessKey: your access key in CSE
      secretKey: your secret key in CSE
      akskCustomCipher: default
  ```

* comsumer端

  ```yaml
  cse-config-order: 100
  APPLICATION_ID: spring-cloud-sample
  service_description:
    name: helloconsumer
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
    rest:
      address: 0.0.0.0:7211 # 7211端口与src/main/resources/application.yml中server.port保持一致
    credentials:
      accessKey: your access key in CSE
      secretKey: your secret key in CSE
      akskCustomCipher: default
  ```

## 步骤三：服务动态发现与调用\(Feign+Ribbon+DiscoveryClient\)

### provider端

* provider端仅需要在ServerMain.java中加载相关的配置信息。

```java
@SpringBootApplication
//@EnableDiscoveryClient //删除DiscoveryClient注解
@ImportResource(locations = "classpath*:META-INF/spring/*.bean.xml")
```

### consumer端

* 首先需要在src/main/resources/application.yml新增如下配置。

```yaml
helloprovider:
  ribbon:
    NIWSServerListClassName: org.apache.servicecomb.springboot.starter.discovery.ServiceCombServerList
```

* 其次在ClientMain.java中加载相关的配置。

```java
@SpringBootApplication
@EnableDiscoveryClient
@EnableFeignClients
@ImportResource(locations = "classpath*:META-INF/spring/*.bean.xml")
public class ClientMain {

    public static void main(String[] args) {
        SpringApplication.run(ClientMain.class, args);
    }
}
```

## 结果验证：启动服务，并分别进行调用，均调用成功

通过运行ServerMain和ClientMain，并登陆华为云CSE环境[https://console.huaweicloud.com/cse](https://console.huaweicloud.com/cse。)进入“微服务管理”-“服务目录菜单”，可以看到Spring Cloud注册的服务实例信息。

![](/assets/spring-cloud-integration-005.png)

Provider端url：[http://localhost:7111/hello/sayhi?name=jianghongwei](http://localhost:7111/hello/sayhi?name=jianghongwei)

调用接口：

![](/assets/spring-cloud-integration-006.png)

Consumer端url：[http://localhost:7211/hello?name=jianghongwei](http://localhost:7211/hello?name=jianghongwei)

调用接口：

![](/assets/spring-cloud-integration-007.png)

## 说明：附1和附2提供了两种方式，同样可以达到步骤三的目的

附1：[启用注册和动态发现\(Ribbon+DiscoveryClient\)](/spring-cloudying-yong-gai-zao/dong-tai-fa-xian-fu-wu-shi-li-zhi-discoveryclient-yu-ribbon.md)

附2：[服务动态发现与调用\(Feign+Ribbon+DiscoveryClient\)](/spring-cloudying-yong-gai-zao/dong-tai-fa-xian-fu-wu-shi-li-zhi.md)

