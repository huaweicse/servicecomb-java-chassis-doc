在进行微服务持续迭代开发的过程中，由于新特性在不停的加入，一些过时的特性在不停的修改，接口兼容问题面临巨大的挑战，特别是在运行环境多版本共存（灰度发布）的情况下。本章节主要描述接口兼容管理的一些实践建议，以及在使用CSE过程中碰到了兼容性问题的解决办法。由于微服务一般都通过REST接口对外提供服务，没有特殊说明的情况下，这里的接口都指REST接口。

# 保证接口兼容的实践

为了防止接口兼容问题，开发者在进行接口变更（新增、修改、删除等）的时候，建议遵循下面的一些原则。

1. 只增加接口，不修改、不删除接口。
2. 作为Provider，增加接口的时候，相应的将微服务版本号递增。比如将2.1.2修改为2.1.3。
3. 作为Consumer，使用Provider的新接口时候，指定Provider的最小版本号。比如：cse.references.\[serviceName\].version-rule=2.1.3+，其中serviceName为Provider的微服务名称。
4. 在服务中心，定期清理不再使用的老版本的微服务信息。

# 接口兼容常见问题及其解决办法

开发阶段，由于存在频繁的接口修改，也不会清理服务中心的数据，容易出现调试的时候接口调用失败的情况。建议开发者可以安装下载一个[服务中心的frontend](https://github.com/apache/incubator-servicecomb-service-center/releases), 可以随时清理服务中心数据。

如果使用华为公有云在线的服务中心，可以直接登录使用微服务引擎提供的管理功能进行删除。

发布阶段，需要审视下接口兼容的实践的步骤，确保不在线上引入接口兼容问题。

如果不小心漏了其中的某个步骤，则可能导致如下一些接口兼容问题：

1. 如果修改、删除接口：导致一些老的Consumer将请求路由到新的Provider，调用失败。
2. 如果忘记修改微服务版本号：导致一些新的Consumer将请求路由到老的Provider，调用失败。
3. 如果忘记配置Consumer的最小依赖版本：当部署顺序为先停止Consumer，再启动Consumer，再停止Provider，再启动Provider的情况，Consumer无法获取到新接口信息，就采用了老接口，当Provider启动以后，Consumer发起对新接口的调用会失败；或者在Provider没启动前，调用新接口失败等。

出现问题的规避措施：出现的接口兼容问题不同，处理方式会有差异。极端情况，只需要清理Provider、Consumer的微服务信息，然后重启微服务即可。当服务调用关系复杂的情况下，接口兼容问题影响范围会更加广泛，同时清理Provider、Consumer数据会变得复杂，因此建议遵循上面的规范，避免不兼容的情况发生。



# 常见的接口不兼容情况的日志

* consumer method \[com.huawei.paas.cse.demo.CodeFirstPojoIntf:testUserMap\] not exist in swagger

可能是Provider增加了接口，但是没有更新版本号。需要删除微服务数据或者更新版本号后重新启动Provider，并重启Consumer。



* 


