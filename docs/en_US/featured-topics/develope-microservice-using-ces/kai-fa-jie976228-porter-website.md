在技术选择上，界面完全由html/js/css等构成，不采用其他动态技术。因此只需要有一个可以支持静态页面的服务即可。在架构图中，界面的请求需要被网关转发，并且需要支持多实例部署，因此界面服务需要增加的功能是服务注册和发现。CSE提供了两种方法集成和使用J2EE：

1. 运行于独立的web服务器中，如tomcat等；

2. 运行于Spring Boot的Embeded Tomcat中。

为了部署简单，我们的示例选择了第二种方式。第一种方式也是很简单的，可以参考示例：

[https://github.com/huawei-microservice-demo/HouseApp/tree/master/customer-website](https://github.com/huawei-microservice-demo/HouseApp/tree/master/customer-website) 。

在Spring Boot中提供静态页面服务，核心问题是解决服务注册、发现能力。在Spring Boot的Embeded Tomcat中使用CSE的服务注册发现，需要完成如下步骤：

* 增加依赖关系

依赖关系定义了对于Spring Boot的依赖和CSE的依赖。

```
<dependency>

  <groupId>org.apache.servicecomb</groupId>

  <artifactId>spring-boot-starter-transport</artifactId>

</dependency>

<dependency>

  <groupId>org.springframework.boot</groupId>

  <artifactId>spring-boot-starter-web</artifactId>

</dependency>
```

按照Spring Boot的惯例，需要声明项目的parent。尽管这个步骤不是必须的，但是不增加时需要手工配置很多编译插件，非常繁琐。

```
<parent>

  <groupId>org.springframework.boot</groupId>

  <artifactId>spring-boot-starter-parent</artifactId>

  <version>1.4.5.RELEASE</version>

</parent>
```

* 配置微服务信息\(microservice.yaml\)

需要注意配置项cse.rest.address的端口与application.yml的server.port保持一致。application.yml是Spring Boot的配置文件，用于指定Embeded Tomcat的监听端口。microservice.yam的信息用于服务注册。另外也需要注意一下配置项servicecomb.rest.servlet.urlPattern，当使用@EnableServiceComb时，会加载CSE提供的REST框架org.apache.servicecomb.transport.rest.servlet. RestServlet，而且默认接管了/\*的请求。在我们的场景下，仅仅需要提供web页面，不需要提供REST服务，这个配置项的含义就是将它的路径改为一个和静态页面不冲突的路径，以保证静态页面能够被正常访问。

```
APPLICATION_ID: porter
service_description:
  name: porter-website
  version: 0.0.1

cse:
  rest:
    address: 0.0.0.0:9093

servicecomb:
  rest:
    servlet:
      urlPattern: /servicecomb/rest/*
```

* 增加静态页面

按照Spring Boot的惯例，静态页面需要放到源代码的resources/static目录。项目开始前，增加了如下静态页面和目录：

```
css
js
index.html
```

* 使用@EnableServiceComb启用CSE注册发现

```
@SpringBootApplication
@EnableServiceComb
public class WebsiteMain {
    public static void main(final String[] args) {
        SpringApplication.run(WebsiteMain.class, args);
    }
}
```

经过以上的步骤，界面服务就开发完成了。通过运行WebsiteMain，就可以通过[http://localhost:9093](http://localhost:9093) 来访问。

