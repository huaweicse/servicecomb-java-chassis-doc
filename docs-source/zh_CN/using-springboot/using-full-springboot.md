## 概念阐述

本小节介绍了在Java Chassis框架中集成SpringBoot框架的好处和操作步骤。

## 场景描述

### **SpringBoot框架**

Spring Boot是由Pivotal团队提供的全新框架，其设计目的是用来简化新Spring应用的初始搭建以及开发过程。该框架使用了特定的方式来进行配置，从而使开发人员不再需要定义样板化的配置。从最根本上来讲，Spring Boot就是一些库的集合，它能够被任意项目的构建系统所使用。Boot的功能是模块化的，通过导入Boot所谓的"starter"模块，可以将许多的依赖添加到工程中。

### **在CSE中集成SpringBoot**

使用原生的Java Chassis框架开发微服务应用，如若需要使用Java Chassis框架提供的各项功能服务，需要在微服务项目工程pom文件中添加相应的依赖包，例如需要使用Java Chassis框架提供的负载均衡服务，需要添加handler-loadbalance包依赖。这样可以把CSE提供的能力以starter的方式插入SpringBoot中，同时使用SpringBoot中提供的其他开箱即用的starter（例如SpringCloud）一起构建微服务。

## CSE集成SpringBoot

首先使用Java Chassis框架开发微服务应用，然后在这个基础上集成SpringBoot框架。

使用Java Chassis框架开发微服务应用，详细步骤请参考**3 开发服务提供者**与**4 开发服务消费者**。

在Java Chassis框架中集成SpringBoot：

在对应用进行SpringBoot框架适配前，请确保应用能够正常运行，并且能够从中央的maven库下载依赖的资源。

* **步骤 1**在工程pom文件添加&lt;dependencyManagement&gt;节点：

```xml
<dependencyManagement> 
  <dependencies> 
    <dependency> 
      <groupId>org.apache.servicecomb</groupId>  
      <artifactId>java-chassis-dependencies</artifactId>  
      <version>1.0.0.B003</version>  
      <type>pom</type>  
      <scope>import</scope> 
    </dependency> 
  </dependencies> 
</dependencyManagement>
```

* **步骤 2**添加如下依赖：

\#引用cse提供的springboot依赖

```xml
<dependency> 
    <groupId>org.apache.servicecomb</groupId>  
    <artifactId>spring-boot-starter-provider</artifactId> 
</dependency>
```

\#引用springboot依赖

```xml
<dependency> 
    <groupId>org.springframework.boot</groupId>  
    <artifactId>spring-boot-starter-web</artifactId> 
</dependency>
<dependency> 
    <groupId>org.springframework.boot</groupId>  
    <artifactId>spring-boot-starter-actuator</artifactId> 
</dependency>
```

* **步骤 3**在resources目录下新建application.yml文件，文件内容如下：

```yaml
server: 
  port: 7999    #此处的端口为springboot服务端口
```

* **步骤 4**为微服务启动类添加注解：

```java
@SpringBootApplication //新增注解
@EnableServiceComb //新增注解
public class xxxServerOrClient {
    public static void main(final String[] args) {
        Log4jUtils.init();
        //BeanUtils.init();   
        SpringApplication.run(xxxServerOrClient.class, args)
    }
}
```

* **步骤 5　**Run/Debug Application



