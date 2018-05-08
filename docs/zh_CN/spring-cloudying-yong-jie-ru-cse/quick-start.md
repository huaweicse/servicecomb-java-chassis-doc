本章节通过一个实际的案例，说明Spring Cloud应用如何经过少量的配置修改，快速接入CSE。

* 原始Spring Cloud应用下载地址：

[https://registry.cn-north-1.huaweicloud.com/swr/v2/domains/hwcse/namespaces/hwcse/repositories/default/packages/springcloud-demo/versions/0.0.1/file\_paths/springcloud-sample.zip](https://registry.cn-north-1.huaweicloud.com/swr/v2/domains/hwcse/namespaces/hwcse/repositories/default/packages/springcloud-demo/versions/0.0.1/file_paths/springcloud-sample.zip)

该Spring Cloud应用提供了3个项目：

* eureka-server 提供注册发现能力。
* springcloud-provider 服务提供者，该服务提供了名称为HelloService的REST接口。
* springcloud-consumer 服务消费者，该服务也提供了名称为HelloService的REST接口，其实现通过Feign调用springcloud-provider的REST接口。

改造后的应用具备如下能力和变化：

* 使用CSE提供的服务中心作为注册发现服务；
* 使用CSE提供的配置中心作为动态配置服务，可以通过配置中心管理公共配置；
* 业务的其他逻辑不发生任何变化，写代码的方式也不发生变化。开发者仍然可以按照原来的开发习惯书写业务代码。

# 接入步骤

CSE为Spring Cloud应用提供了非常简单的接入方式，开发者只需要修改依赖关系和少量的配置，就可以启用服务中心和配置中心客户端连接功能，将Spring Cloud应用作为一个CSE的微服务注册到服务中心和使用动态配置能力。

* 建议开发者在pom.xml中引入依赖的dependencyManagement，以便更好的管理使用的三方件，防止冲突。

dependencyManagement不会往程序里面增加依赖关系，但是可以帮助开发者更好的管理依赖关系，对于解决三方软件冲突非常有用。详细原理描述可以参考“[使用maven管理复杂依赖关系的技巧](http://servicecomb.incubator.apache.org/cn/docs/maven_dependency_management/)"。

```
    <dependencyManagement>
        <dependencies>
            <dependency>
                <groupId>com.huawei.paas.cse</groupId>
                <artifactId>cse-dependency</artifactId>
                <version>2.3.19</version>
                <type>pom</type>
                <scope>import</scope>
            </dependency>
        </dependencies>
    </dependencyManagement>
```

* 修改依赖关系

将Spring Cloud中对于earuka的依赖换成CSE的依赖。

Eureka的依赖：开发者一般会使用spring-cloud-starter-eureka。spring-cloud-starter-eureka-server是作为注册服务使用的，替换服务中心后不需要继续使用。

```
<dependency>
    <groupId>org.springframework.cloud</groupId>
    <artifactId>spring-cloud-starter-eureka</artifactId>
</dependency>

<dependency>
    <groupId>org.springframework.cloud</groupId>
    <artifactId>spring-cloud-starter-eureka-server</artifactId>
</dependency>
```

修改后的依赖：

```
<dependency>
    <groupId>com.huawei.paas.cse</groupId>
    <artifactId>cse-solution-spring-cloud</artifactId>
</dependency>
```

* Consumer使用ribbon

如果Spring Cloud应用代码中使用了Ribbon组件，它默认的实现是通过Eureka的，需要在application.yml中增如下配置：

```
helloprovider:
  ribbon:
    NIWSServerListClassName: org.apache.servicecomb.springboot.starter.discovery.ServiceCombServerList
```

经过上面步骤，就完成了Spring Cloud应用接入CSE的全部整改。开发者可以将应用打包为容器镜像，在华为云上进行部署。



# 补充说明

将应用制作为镜像，部署到华为云，部署平台会对应用增加一些认证关系的配置，以完成对于应用的安全认证，这些过程是由部署平台自动完成的。CSE的服务中心和配置中心提供api gateway开放了REST接口，支持开发者在公网环境使用其服务，这样给开发者的线下开发带来大量的便利。为了线下使用CSE的服务中心和配置中心，开发者需要在application.yml中增加认证信息，认证信息包含AS/SK，可以从华为云账号的"[我的凭证](https://support.huaweicloud.com/usermanual-iam/zh-cn_topic_0079477318.html)”获取。

```
cse:
  credentials:
    accessKey: your access key
    secretKey: your secret key
    akskCustomCipher: default
```

有些开发者需要通过代理服务器访问华为云，也可以通过设置代理来实现：

```
cse:
  proxy:
    enable: true
    host: your proxy server
    port: your proxy server port
    username: user name
    passwd: password for proxy 
```



