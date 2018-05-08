## 概述

结合微服务框架，进行第一个微服务HelloWorld应用的开发。

通过这个例子，你将学会：

* 定义一个远程服务接口
* provider发布远程服务到注册中心
* consumer自动发现远程服务并完成服务调用

## 操作步骤

### 步骤 1配置maven

CSE的发布件在华为云提供的maven仓库中，需要在maven setting文件中指定对应的仓库，使得能够下载CSE相关依赖包。

```
<mirror>
  <id>mirrorId</id>
  <mirrorOf>*</mirrorOf>
  <name>Mirror of central repository.</name>
  <url>http://maven.huaweicse.com/nexus/content/groups/public</url>
</mirror>
```

### 步骤 2引入POM依赖包

修改项目的pom文件，引入相应的微服务框架依赖包。

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

<dependencies> 
  <dependency> 
    <groupId>com.huawei.paas.cse</groupId>  
    <artifactId>cse-solution-service-engine</artifactId> 
  </dependency>
</dependencies>
```

### 步骤 3修改配置。

1.配置微服务信息

在src/main/resources目录下面创建microservice.yaml文件，用于存放sdk配置信息。

```yaml
APPLICATION_ID: helloTest

service_description:
  name: helloClient
  version: 0.0.1
cse:
  service:
    registry:
      address: http://127.0.0.1:30100
```

2.日志文件配置（可选）

在src/main/resources目录下面创建config目录，添加log4j.hello.properties配置文件，日志配置文件命名规则为log4j.\*.properties，内容如下。

```
paas.logs.dir=../logs/ #日志文件目录
paas.logs.file=hello.log #日志文件名
log4j.rootLogger=INFO,paas,stdout
```

### 步骤 4定义服务接口：（该接口需单独打包，在服务提供方和消费方共享）

HelloWorldService.java

根据契约编写业务接口，如下：

```java
public interface HelloWorldService{
  String sayHello(String name);
}
```

### 步骤 5Provider实现

* 服务提供方实现接口（对服务消费方隐藏实现）：

```java
@RpcSchema(schemaId="hello")
public class HelloWorldServiceImpl implements HelloWorldService{
  public String sayHello(String name) {
    return "hello " + name;
  }
}
```

* 编写Main启动函数：

```java
public class Provider{
  public static void main(String[] args) throws Exception {
    Log4jUtils.init(); //日志初始化
    BeanUtils.init(); //Spring初始化
  }
}
```

### 步骤 6 Consumer实现

* 服务调用声明

在文件META-INF/spring/hello.bean.xml中声明如下：

```
<?xml version="1.0" encoding="utf-8"?>

<beans xmlns="http://www.springframework.org/schema/beans" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:p="http://www.springframework.org/schema/p" xmlns:util="http://www.springframework.org/schema/util" xmlns:cse="http://www.huawei.com/schema/paas/cse/rpc" xsi:schemaLocation="http://www.springframework.org/schema/beans classpath:org/springframework/beans/factory/xml/spring-beans-3.0.xsd http://www.huawei.com/schema/paas/cse/rpc classpath:META-INF/spring/spring-paas-cse-rpc.xsd">  
  <cse:rpc-reference id="helloworld" schema-id="helloworld" microservice-name="helloServer"></cse:rpc-reference> 
</beans>
```

* 服务调用

Consumer.java

```java
public class Consumer{
   public static void main(String[] args) throws Exception {
     Log4jUtils.init(); #日志初始化
     BeanUtils.init(); # Spring bean初始化
     HelloWorld hello = BeanUtils.getBean("helloworld")#服务调用
     System.out.println(hello.sayHello("world"));
  }
}
```

### 步骤 7服务注册

* 启动服务中心

服务中心单机版安装包为cse-service-center-standalone.tar.gz，现在只支持64位，解压之后，单击安装包里的start.bat脚本即可启动服务中心（linux环境下运行start.sh）。

* 使用华为云在线中间件

开发者只需要注册华为云用户，获得相应的AK、SK认证信息，即可直接使用在线服务，省去了本地按照服务的麻烦。还可以在线监控自己的服务状态。使用在线的服务，只需要将连接信息配置为对应的域名，并设置AK、SK：

```
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
      refresh_interval: 5000
  monitor:
    client:
      serverUri: https://cse.cn-north-1.myhwclouds.com:443
  credentials:
    accessKey: your access key
    secretKey: your secret key
    akskCustomCipher: default
```



