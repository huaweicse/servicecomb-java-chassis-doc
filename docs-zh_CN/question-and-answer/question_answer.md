# 问题描述：如何自定义某个Java方法对应的REST接口里的HTTP Status Code？

** 解决方法：**

对于正常的返回值，可以通过SwaggerAnnotation实现，例如：

```java
@ApiResponse(code = 300, response = String.class, message = "")
public int test(int x) {
  return 100;
}
```

对于异常的返回值，可以通过抛出自定义的InvocationException实现，例如：、

```java
    public String testException(int code) {
        String strCode = String.valueOf(code);
        switch (code) {
            case 200:
                return strCode;
            case 456:
                throw new InvocationException(code, strCode, strCode + " error");
            case 556:
                throw new InvocationException(code, strCode, Arrays.asList(strCode + " error"));
            case 557:
                throw new InvocationException(code, strCode, Arrays.asList(Arrays.asList(strCode + " error")));
            default:
                break;
        }

        return "not expected";
    }
```

# 问题描述： 如何定制自己微服务的日志配置

** 解决方法：**  
ServiceComb不绑定日志器，只是使用了slf4j，用户可以自由选择log4j/log4j2/logback等等。ServiceComb提供了一个log4j的扩展，在标准log4j的基础上，支持log4j的properties文件的增量配置。

* 默认以规则："classpath\*:config/log4j.properties"加载配置文件
* 实际会搜索出classpath中所有的`config/log4j.properties和config/log4j.*.properties`, 从搜索出的文件中切出`\*`的部分，进行alpha排序，然后按顺序加载，最后合成的文件作为log4j的配置文件。
* 如果要使用ServiceComb的log4j扩展，则需要调用Log4jUtils.init，否则完全按标准的日志器的规则使用。

# 问题描述： 当服务配置了多个transport的时候，在运行时是怎么选择使用哪个transport的？

** 解决方法：**

* ServiceComb的consumer、transport、handler、producer之间是解耦的，各功能之间通过契约定义联合在一起工作的，即：  
  consumer使用透明rpc，还是springmvc开发与使用highway，还是RESTful在网络上传输没有关系与producer是使用透明rpc，还是jaxrs，或者是springmvc开发，也没有关系handler也不感知，业务开发方式以及传输方式

* consumer访问producer，在运行时的transport选择上，总规则为：  
  consumer的transport与producer的endpoint取交集，如果交集后，还有多个transport可选择，则轮流使用

分解开来，存在以下场景：

* 当一个微服务producer同时开放了highway以及RESTful的endpoint
  * consumer进程中只部署了highway transport jar，则只会访问producer的highway endpoint
  * consumer进程中只部署了RESTful transport jar，则只会访问producer的RESTful endpoint
  * consumer进程中，同时部署了highway和RESTful transport jar，则会轮流访问producer的highway、RESTful endpoint

如果，此时consumer想固定使用某个transport访问producer，可以在consumer进程的microservice.yaml中配置，指定transport的名称:

```
servicecomb:
  references:
    <service_name>:
      transport: highway
```

* 当一个微服务producer只开放了highway的endpoint

  * consumer进程只部署了highway transport jar，则正常使用higway访问
  * consumer进程只部署了RESTful transport jar，则无法访问
  * consumer进程同时部署了highway和RESTful transport jar，则正常使用highway访问

* 当一个微服务producer只开放了RESTful的endpoint

  * consumer进程只部署了highway transport jar，则无法访问
  * consumer进程只部署了RESTful transport jar，则正常使用RESTful访问
  * consumer进程同时部署了highway和RESTful transport jar，则正常使用RESTful访问

# 问题描述： swagger body参数类型定义错误，导致服务中心注册的内容没有类型信息

**现象描述:**

定义如下接口，将参数放到body传递

```
/testInherate:
    post:
      operationId: "testInherate"
      parameters:
      - in: "body"
        name: "xxxxx"
        required: false
        type: string
      responses:
        200:
          description: "response of 200"
          schema:
            $ref: "#/definitions/ReponseImpl"
```

采用上面方式定义接口。在服务注册以后，从服务中心查询下来的接口type: string 丢失，变成了：

```
/testInherate:
    post:
      operationId: "testInherate"
      parameters:
      - in: "body"
        name: "xxxxx"
        required: false
      responses:
        200:
          description: "response of 200"
          schema:
            $ref: "#/definitions/ReponseImpl"
```

如果客户端没有放置swagger，还会报告如下异常：

Caused by: java.lang.ClassFormatError: Method "testInherate" in class ? has illegal signature "

**解决方法：**

定义body参数的类型的时候，需要使用schema，不能直接使用type。

```
/testInherate:
    post:
      operationId: "testInherate"
      parameters:
      - in: "body"
        name: "request"
        required: false
        schema:
          type: string
      responses:
        200:
          description: "response of 200"
          schema:
            $ref: "#/definitions/ReponseImpl"
```

# 问题描述：CSE微服务框架服务调用是否使用长连接

** 解决方法：**

http使用的是长连接（有超时时间），highway方式使用的是长连接（一直保持）。

# 问题描述：服务断连服务中心注册信息是否自动删除

** 解决方法：**

服务中心心跳检测到服务实例不可用，只会移除服务实例信息，服务的静态数据不会移除。

# 问题描述：如果使用tomcat方式集成CSE微服务框架，如何实现服务注册

** 解决方法：**

如果使用cse sdk servlet方式（使用transport-rest-servlet依赖）制作为war包部署到tomcat，需要保证，服务描述文件（microservice.yaml）中rest端口配置和外置容器一致才能实现该服务的正确注册。否则无法感知tomcat开放端口。

# 问题描述：如果使用tomcat方式集成CSE微服务框架，服务注册的时候如何将war包部署的上下文注册到服务中心

** 解决方法：**

发布服务接口的时候需要将war包部署的上下文（context）放在baseurl最前面，这样才能保证注册到服务中心的路径是完整的路径（包含了上下文）。实例：

```java
@path(/{context}/xxx)
class ServiceA
```

# 问题描述：CSE微服务框架如何实现数据多个微服务间透传

** 解决方法：**

透传数据塞入：

```java
CseHttpEntity<xxxx.class> httpEntity = new CseHttpEntity<>(xxx);
//透传内容
httpEntity.addContext("contextKey","contextValue");
ResponseEntity<String> responseEntity = RestTemplateBuilder.create().exchange("cse://springmvc/springmvchello/sayhello",HttpMethod.POST,httpEntity,String.class);
```

透传数据获取：

```java
@Override
@RequestMapping(path="/sayhello",method = RequestMethod.POST)
public String sayHello(@RequestBody Person person,InvocationContext context){
    //透传数据获取
    context.getContext();
    return "Hello person " + person.getName();
}
```

# 问题描述：CSE微服务框架服务如何自定义返回状态码

** 解决方法：**

```java
@Override
@RequestMapping(path = "/sayhello",method = RequestMethod.POST)
public String sayHello(@RequestBody Person person){
    InvocationContext context = ContextUtils.getInvocationContext();
    //自定义状态码
    context.setStatus(Status.CREATED);
    return "Hello person "+person.getName();
}
```

# 问题描述：CSE body Model部分暴露

** 解决方法：**

一个接口对应的body对象中，可能有一些属性是内部的，不想开放出去，生成schema的时候不要带出去，使用：

```java
@ApiModelProperty(hidden = true)
```

# 问题描述：CSE框架获取远端consumer的地址

** 解决方法：**

如果使用http rest方式（使用transport-rest-vertx依赖）可以用下面这种方式获取：

```java
HttpServletRequest request = (HttpServletRequest) invocation.getHandlerContext().get(RestConst.REST_REQUEST);
String host = request.getRemoteHost();
```

实际场景是拿最外层的地址，所以应该是LB传入到edgeservice，edgeService再放到context外下传递。

# 问题描述：CSE不支持泛型

** 解决方法：**

明确不支持，需要修改接口，接口修改后需要修改版本号，以免consumer还是使用旧的版本。

# 问题描述：CSE对handler描述

** 解决方法：**

consumer默认的handler是simpleLB，没有配置的时候handler链会使用这个，如果配置了handler，里面一定要包含lb的handler，否则调用报错，需要在文档里面进行说明。

# 问题描述：CSE日志替换

** 解决方法：**

CSE java-chassis日志推荐方式是在启动的时候使用Log4jUtils.init\(\)，直接使用推荐的Log4j来做日志管理，但是有些场景不想用log4j，比如想使用log4j2或者logback，下面以log4j2为例简单介绍下步骤：

1. 在代码里面不要使用Log4jUtils.init\(\)；
2. 去掉log4j的配置文件（不删掉也没关系，因为不会使用）；
3. exclude掉CSE框架引入的log4j，例如：
   ```xml
   <dependency>
       <groupId>org.apache.servicecomb</groupId>
       <artifactId>provider-springmvc</artifactId>
       <exclusions>
           <exclusion>
               <groupId>log4j</groupId>
               <artifactId>log4j</artifactId>
           </exclusion>
       </exclusions>
   </dependency>
   <dependency>
       <groupId>com.huawei.paas.cse</groupId>
       <artifactId>cse-handler-tcc</artifactId>
       <exclusions>
           <exclusion>
               <groupId>log4j</groupId>
               <artifactId>log4j</artifactId>
           </exclusion>
           <exclusion>
               <groupId>org.slf4j</groupId>
               <artifactId>slf4j-log4j12</artifactId>
           </exclusion>
       </exclusions>
   </dependency>
   ```
4. 引入log4j2的依赖

   ```xml
   <dependency>    
       <groupId>org.apache.logging.log4j</groupId>
       <artifactId>log4j-slf4j-impl</artifactId>
   </dependency>
   <dependency>
       <groupId>org.apache.logging.log4j</groupId>
       <artifactId>log4j-api</artifactId>
   </dependency>
   <dependency>
       <groupId>org.apache.logging.log4j</groupId>
       <artifactId>log4j-core</artifactId>
   </dependency>
   ```

   如果没有版本依赖管理，还需要填写上版本号。

5. 加入log4j2的配置文件log4j2.xml，关于这个请查看官方说明，例如：

   ```xml
    <?xml version="1.0" encoding="UTF-8"?>
    <!--日志级别以及优先级排序: OFF > FATAL > ERROR > WARN > INFO > DEBUG > TRACE > ALL -->
    <!--Configuration后面的status，这个用于设置log4j2自身内部的信息输出，可以不设置，当设置成trace时，你会看到log4j2内部各种详细输出-->
    <!--monitorInterval：Log4j能够自动检测修改配置 文件和重新配置本身，设置间隔秒数-->
    <configuration status="WARN" monitorInterval="30">
        <!--先定义所有的appender-->
        <appenders>
        <!--这个输出控制台的配置-->
            <console name="Console" target="SYSTEM_OUT">
            <!--输出日志的格式-->
                <PatternLayout pattern="[%d{HH:mm:ss:SSS}] [%p] - %l - %m%n"/>
            </console>
            <!--文件会打印出所有信息，这个log每次运行程序会自动清空，由append属性决定，这个也挺有用的，适合临时测试用-->
            <File name="log" fileName="log/test.log" append="false">
               <PatternLayout pattern="%d{HH:mm:ss.SSS} %-5level %class{36} %L %M - %msg%xEx%n"/>
            </File>
            <!-- 这个会打印出所有的info及以下级别的信息，每次大小超过size，则这size大小的日志会自动存入按年份-月份建立的文件夹下面并进行压缩，作为存档-->
            <RollingFile name="RollingFileInfo" fileName="${sys:user.home}/logs/info.log"
                         filePattern="${sys:user.home}/logs/$${date:yyyy-MM}/info-%d{yyyy-MM-dd}-%i.log">
                <!--控制台只输出level及以上级别的信息（onMatch），其他的直接拒绝（onMismatch）-->
                <ThresholdFilter level="info" onMatch="ACCEPT" onMismatch="DENY"/>
                <PatternLayout pattern="[%d{HH:mm:ss:SSS}] [%p] - %l - %m%n"/>
                <Policies>
                    <TimeBasedTriggeringPolicy/>
                    <SizeBasedTriggeringPolicy size="100 MB"/>
                </Policies>
            </RollingFile>
            <RollingFile name="RollingFileWarn" fileName="${sys:user.home}/logs/warn.log"
                         filePattern="${sys:user.home}/logs/$${date:yyyy-MM}/warn-%d{yyyy-MM-dd}-%i.log">
                <ThresholdFilter level="warn" onMatch="ACCEPT" onMismatch="DENY"/>
                <PatternLayout pattern="[%d{HH:mm:ss:SSS}] [%p] - %l - %m%n"/>
                <Policies>
                    <TimeBasedTriggeringPolicy/>
                    <SizeBasedTriggeringPolicy size="100 MB"/>
                </Policies>
                <!-- DefaultRolloverStrategy属性如不设置，则默认为最多同一文件夹下7个文件，这里设置了20 -->
                <DefaultRolloverStrategy max="20"/>
            </RollingFile>
            <RollingFile name="RollingFileError" fileName="${sys:user.home}/logs/error.log"
                         filePattern="${sys:user.home}/logs/$${date:yyyy-MM}/error-%d{yyyy-MM-dd}-%i.log">
                <ThresholdFilter level="error" onMatch="ACCEPT" onMismatch="DENY"/>
                <PatternLayout pattern="[%d{HH:mm:ss:SSS}] [%p] - %l - %m%n"/>
                <Policies>
                    <TimeBasedTriggeringPolicy/>
                    <SizeBasedTriggeringPolicy size="100 MB"/>
                </Policies>
            </RollingFile>
        </appenders>
        <!--然后定义logger，只有定义了logger并引入的appender，appender才会生效-->
        <loggers>
            <!--过滤掉spring和mybatis的一些无用的DEBUG信息-->
            <logger name="org.springframework" level="INFO"></logger>
            <logger name="org.mybatis" level="INFO"></logger>
            <root level="all">
                <appender-ref ref="Console"/>
                <appender-ref ref="RollingFileInfo"/>
                <appender-ref ref="RollingFileWarn"/>
                <appender-ref ref="RollingFileError"/>
            </root>
        </loggers>
    </configuration>
   ```

6. 启动服务进行验证

# 问题描述：netty版本问题

** 解决方法：**

netty3和netty4是完全不同的三方件，因为坐标跟package都不相同，所以可以共存，但是要注意小版本问题，小版本必须使用CSE的版本。

# 问题描述：CSE服务超时设置

** 解决方法：**

在微服务描述文件（microservice.yaml）中添加如下配置：

```
cse:
  request:
    timeout: 30000
```

# 问题描述：服务治理的处理链顺序是否有要求？

**解决方法：**

处理链的顺序不同，那么系统工作行为也不同。 下面列举一下常见问题。

1、loadbalance和bizkeeper-consumer

这两个顺序可以随机组合。但是行为是不一样的。

当loadbalance在前面的时候，那么loadbalance提供的重试功能会在bizkeeper-consumer抛出异常时发生，比如超时等。但是如果已经做了fallbackpolicy配置，比如returnnull，那么loadbalance则不会重试。

如果loadbalance在后面，那么loadbalance的重试会延长超时时间，即使重试成功，如果bizkeeper-consumer设置的超时时间不够，那么最终的调用结果也是失败。

2、tracing-consumer，sla-consumer，tracing-provider，sla-provider

这些处理链建议放到处理链的最开始位置，保证成功、失败的情况都可以记录日志（由于记录日志需要IP等信息，对于消费者，只能放到loadbalance后面）。

如果不需要记录客户端返回的异常，则可以放到末尾，只关注网络层返回的错误。但是如果bizkeeper-consumer等超时提前返回的话，则可能不会记录日志。

3、建议的顺序

Consumer: loadbalance, tracing-consumer, sla-consumer, bizkeeper-consumer

Provider: tracing-provider, sla-provider, bizkeeper-provider

这种顺序能够满足大多数场景，并且不容易出现不可理解的错误。

# 问题描述：服务解析域名失败

**现象描述：**

在云上部署时，如果缺少配置或缺少对应依赖，会报解析域名失败的错误。

**解决方法：**

方法1：

在pom里添加依赖cse-solution-service-engine

```xml
<dependency>
  <groupId>com.huawei.paas.cse</groupId>  
  <artifactId>cse-solution-service-engine</artifactId> 
</dependency>
```

方法2：

在微服务描述文件（microservice.yaml）中添加如下配置：

```xml
addressResolver:
  searchDomains: default.svc.cluster.local,svc.cluster.local,cluster.local
  ndots: 1
```





