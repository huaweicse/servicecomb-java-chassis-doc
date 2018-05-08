## 概念阐述

调用性能统计模块用于在开发阶段在标准输出控制台中输出请求的执行时间和系统吞吐量等信息，让开发者能够看到系统的性能状况。

> zipkin是分布式链路调用监控系统，聚合各业务系统调用延迟数据，达到链路调用监控跟踪。

## 场景描述

性能统计模块能输出系统的rpc性能统计，包括调用次数、平均延迟、调用延迟区间分布情况，如下图所示：![](/start/调用性能统计.png)

## 配置说明

表1-1配置项说明

| 配置项 | 参考/默认值 | 取值范围 | 是否必选 | 含义 | 注意 |
| :--- | :--- | :--- | :--- | :--- | :--- |
| cse.metrics.enabled | TRUE | {TRUE,FALSE} | 否 | 是否输出性能日志统计 |  |
| cse.metrics.cycle.ms | 60000 | \[0,+∞\) | 否 | 输出性能日志统计的时间间隔 |  |

## 示例代码

步骤1 首先在项目工程pom.xml文件中添加性能统计模块依赖：

```xml
<dependency>
  <groupId>com.huawei.paas.cse</groupId>
  <artifactId>cse-handler-performance-stats</artifactId>
</dependency>
```

步骤2 在microservices.yaml中添加性能统计处理链，配置性能统计属性：

* 服务端：

```yaml
cse: 
  handler: 
    chain: 
      Provider: 
        default: perf-stats#添加调用性能统计模块
  #性能统计属性
  metrics: 
    enabled: true #是否输出性能日志统计
      cycle: 
        ms: 10000 #输出性能日志统计时间间隔
```

* 客户端：

```yaml
cse: 
  handler: 
    chain:  
      Consumer: 
        default: bizkeeper-consumer,loadbalance,perf-stats
  #性能统计属性
  metrics: 
    enabled: true
    cycle: 
      ms: 10000
```



