## 服务动态发现与调用\(Feign+Ribbon+DiscoveryClient\)

本章节说明：

1. 使用Feign，DiscoveryClient和Ribbon。
2. 用户可在新增的Ribbon配置类中自定义相关配置，如指定服务端SSL，指定schema为http或https

### provider端

* provider端仅需要在ServerMain.java中里面加载相关的配置信息。

```java
@SpringBootApplication
//@EnableDiscoveryClient //删除DiscoveryClient注解
@ImportResource(locations = "classpath*:META-INF/spring/*.bean.xml")
```

### consumer端

* 首先需要在src/mainjava/io/consumer目录下新增Ribbon配置类SayhiConfiguration.class。

```java
package io.consumer;

import com.netflix.client.config.IClientConfig;
import com.netflix.loadbalancer.Server;
import com.netflix.loadbalancer.ServerList;
import org.apache.servicecomb.springboot.starter.discovery.ServiceCombServerList;
import org.springframework.context.annotation.Bean;

public class SayhiConfiguration {
    @Bean
    ServerList<Server> ribbonServerList(IClientConfig config) {
        ServiceCombServerList serverList = new ServiceCombServerList();
        serverList.initWithNiwsConfig(config);
        return serverList;
    }
}
```

* 其次在ClientMain.java里面加载相关的配置。

```java
@SpringBootApplication
@EnableDiscoveryClient
@EnableFeignClients
@ImportResource(locations = "classpath*:META-INF/spring/*.bean.xml")
@RibbonClient(name = "helloprovider", configuration = SayhiConfiguration.class)
public class ClientMain {

    public static void main(String[] args) {
        SpringApplication.run(ClientMain.class, args);
    }
}
```