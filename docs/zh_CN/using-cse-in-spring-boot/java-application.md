使用JAVA方式集成，为Spring Boot应用增加了一个高效的HTTP服务器和REST开发框架。这种方式集成非常简单。只需要在项目中引入相关依赖，并且使用@EnableServiceComb标签即可。

项目代码示例参考：

[https://github.com/huawei-microservice-demo/SpringCloudIntegration/blob/master/spring-boot-simple](https://github.com/huawei-microservice-demo/SpringCloudIntegration/blob/master/spring-boot-simple)



* 引入依赖

依赖关系中增加spring-boot-starter-provider，即可引入CSE的核心功能。cse-solution-service-engine增加了接入华为公有云相关的认证模块和治理相关模块，并排除了log4j运行时包，防止和spring boot缺省携带的logback冲突。引入hibernate-validator的目的是spring boot会检测validation-api的实现类，检测不到会无法启动。

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
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter</artifactId>
    </dependency>
    <dependency>
        <groupId>org.hibernate</groupId>
        <artifactId>hibernate-validator</artifactId>
    </dependency>
</dependencies>
```



* 启用CSE的核心功能

在启动类前面增加@EnableServiceComb即可。

```
@SpringBootApplication
@EnableServiceComb
public class WebsiteMain {
    public static void main(final String[] args) {
        SpringApplication.run(WebsiteMain.class, args);
    }
}
```



通过以上配置，就可以完整使用CSE提供的所有功能，使用CSE开发REST服务，并开启各种治理功能。



* 配置微服务

通过microservice.yaml文件可以定制微服务的信息，包括应用名称、微服务名称、监听的地址和端口等。



集成CSE后，可以通过CSE的方式开发REST接口：

```
@RestSchema(schemaId = "hello")
@RequestMapping(path = "/")
public class HelloService {
    @RequestMapping(path = "hello", method = RequestMethod.GET)
    public String sayHello(@RequestParam(name="name") String name) {
        return "Hello " + name;
    }
}
```



然后可以通过：http://localhost:9093/hello?name=world来访问。



