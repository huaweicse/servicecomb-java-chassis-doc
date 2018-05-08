## 服务动态发现与调用（DiscoveryClient+Ribbon）

本章节说明：

1. 仅使用DiscoveryClient和Ribbon。
2. 用户可在新增的Ribbon配置类中自定义相关配置，如指定服务端SSL，指定schema为http或https
3. 需要注入RestTemplate实例

### provider端

* provider端仅需要在ServerMain.java中加载相关的配置信息。

```java
@SpringBootApplication
//@EnableDiscoveryClient //删除DiscoveryClient注解
@ImportResource(locations = "classpath*:META-INF/spring/*.bean.xml")
```

### consumer端

* 首先需要在src/main/java/io/consumer目录下新增Ribbon配置类SayhiConfiguration.class。

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

* 其次在ClientMain.java里面加载相关的配置同时删除@EnableFeignClients注解，并注入RestTemplate实例。此外，Consumer端使用RestTemplate替代Feign，Hello.java中@FeignClient和@RequestMapping注解需要删除

```java
@SpringBootApplication
@EnableDiscoveryClient
//@EnableFeignClients  //删除Feign配置
@ImportResource(locations = "classpath*:META-INF/spring/*.bean.xml")
@RibbonClient(name = "helloprovider", configuration = SayhiConfiguration.class)
public class ClientMain {
    @LoadBalanced
    @Bean
    RestTemplate restTemplate() {
        return new RestTemplate();
    }
    public static void main(String[] args) {
        SpringApplication.run(ClientMain.class, args);
    }
}

```

* 调用provider端

```java
@RestController
@RequestMapping(path = "/hello", produces = MediaType.TEXT_PLAIN)
public class HelloService {
    @Autowired
    RestTemplate restTemplate;
    
    @RequestMapping(method = RequestMethod.GET)
    public String hello(String name) {
        return restTemplate.getForObject("http://helloprovider/hello/sayhi?name=" + name, String.class);
    }
}
```





