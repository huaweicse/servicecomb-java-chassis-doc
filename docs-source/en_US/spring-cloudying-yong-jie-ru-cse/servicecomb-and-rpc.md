在上面的章节中，介绍了Spring Cloud如何使用CSE的服务注册发现、动态配置管理等中间件服务。这些操作的基础是Spring RESTful Web Service \(本质上是一个Servlet，即org.springframework.web.servlet.DispatcherServlet\)。ServiceComb作为一个独立的RPC框架实现，可以非常容易集成到Spring Cloud中。通过将Spring RESTful Web Service替换为ServiceComb，可以给开发者带来如下便利：

* 一致的开发体验。使用ServiceComb的SpringMVC模式，可以获得和Spring RESTful Web Service一致的开发体验，包括一样的声明式Annotation，使用RestTemplate进行访问。

* 更好的RPC支持。使用ServiceComb，开发者不需要在客户端使用Feign等组件访问服务，可以直接使用RPC访问，非常灵活。

* 更好的通信性能和协议扩展。这块是ServiceComb的核心部分。

* 完整的开箱即用的服务治理、监控、调用链等功能。达到一键式启用的目的。

本章节的涉及的代码参考：

* 原始Spring Cloud应用来源于官网

[https://spring.io/guides/gs/rest-service/](https://spring.io/guides/gs/rest-service/)

* 使用ServiceComb的示例

[https://github.com/huawei-microservice-demo/SpringCloudIntegration/blob/master/gs-rest-service-with-servicecomb](https://github.com/huawei-microservice-demo/SpringCloudIntegration/blob/master/gs-rest-service-with-servicecomb)

## 集成方式

ServiceComb支持如下几种集成方式，当需要和Spring Cloud集成的时候，ServiceComb可以作为一个Servlet替换org.springframework.web.servlet.DispatcherServlet；也可以作为一个完全独立的HTTP服务器使用。在下面的章节中，重点说明作为完全独立的HTTP服务器使用，开发者可以从ServiceComb官网获取作为Servlet运行在EmbededTomcat的示例。

![](/assets/spring-cloud-integration-004.png)

## 配置依赖关系

通过依赖spring-boot-starter-provider，可以引入对于ServiceComb的依赖。为了简单的接入CSE，还引入了cse-solution-service-engine。

```
<dependency>
    <groupId>org.apache.servicecomb</groupId>
    <artifactId>spring-boot-starter-provider</artifactId>
</dependency>
<dependency>
   <groupId>com.huawei.paas.cse</groupId>
   <artifactId>cse-solution-service-engine</artifactId>
   <exclusions>
      <exclusion>
          <groupId>org.slf4j</groupId>
          <artifactId>slf4j-log4j12</artifactId>
      </exclusion>
  </exclusions>
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

## 配置启动类和定义REST接口

在启动类Application里面加入：@EnableServiceComb。这样就会在启动的时候，加载ServiceCom运行时。

然后开发者就可以定义自己的REST接口（对应于Spring Cloud的Controller）。可以看出和Spring Cloud Controller的差异：

* 使用@RestSchema声明接口，并且指定Schema ID。ServiceComb会对每个REST接口都生成一个接口定义文件，并上传到服务中心。Schema ID在微服务内部需要保持唯一。

* 显示的使用@RequestMapping定义路径。SeviceComb支持JaxRS和SpringMVC两种方式定义REST接口，运行时根据这个标签来区分采用哪种方式生成契约。

其他服务的定义方式和Spring Cloud保持完全一致。ServiceComb支持客户端以RestTemplate和RPC两种方式访问服务端，也可以通过浏览器使用REST的方式直接访问服务端，所以一个好的开发实践是给每个REST服务都定义一个接口IGreetingController。使用ServiceComb，不需要Spring Cloud的声明式REST调用（Feign），可以大大简化开发者的工作量。

```
package hello;

import java.util.concurrent.atomic.AtomicLong;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;

import org.apache.servicecomb.provider.rest.common.RestSchema;

@RestSchema(schemaId = "greeting")
@RequestMapping(path = "/")
public class GreetingController implements IGreetingController {

  private static final String template = "Hello, %s!";

  private final AtomicLong counter = new AtomicLong();


  @Override
  @RequestMapping(value = "/greeting", method = RequestMethod.GET)
  public Greeting greeting(@RequestParam(value = "name", defaultValue = "World") String name) {
    return new Greeting(counter.incrementAndGet(),
        String.format(template, name));
  }
```

## 客户端访问

ServiceComb简化了客户端访问服务端的方式，同时也支持Spring Cloud使用RestTemplate的方式去访问。

* RPC方式

```
@RpcReference(microserviceName = "spring-cloud-with-servicecomb-demo", schemaId = "greeting")
IGreetingController hello;
Greeting result = hello.greeting("test for rpc");
```

* RestTemplate方式

```
RestTemplate restTemplate = RestTemplateBuilder.create();
Greeting result = restTemplate.getForEntity("cse://spring-cloud-with-servicecomb-demo/greeting", Greeting.class).getBody();
```

## 使用服务治理

现在开发者可以启动示例程序，登陆CSE，使用微服务目录、治理配置等各种系统功能，这些功能对于开发者都是立即可用的，有效的把开发者从运维中解放出来，可以全心专注于业务系统的开发。这些功能都是基于动态配置能力实现的，CSE通过动态配置完成了一整套微服务治理的功能，开发者仍然可以通过在microservice.yaml中增加配置项或者通过环境变量实现类似的管控，即使脱离了运行环境，也不担心能力丢失。

开发者可以使用系统界面进行配置验证，然后将配置项参数保存下来，作为运维回馈并预置到新版本中，改善程序健壮性，这是一个很值得尝试的开发实践。

