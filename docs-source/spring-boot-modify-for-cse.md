Spring Cloud应用可以方便的接入CSE提供的基础服务。接入CSE服务有如下好处：

1. 开发者可以专注于业务系统的开发，把精力从中间件的可靠性评估、集群部署、运维监控等复杂的事情中解放出来。

2. 实现业务快速交付和敏捷开发。利用PaaS平台，根据业务规模，动态的调整资源使用，降低业务风险。

下图展现了CSE基础服务、PaaS平台服务和第三方服务的关系：

![](/assets/spring-cloud.png)

CSE官方支持ServiceComb微服务框架接入和Spring Cloud微服务框架接入。两个框架接入的步骤基本类似。在本章节中，主要介绍Spring Cloud应用接入CSE的原理，然后通过一个Spring Cloud应用改造的案例，说明改造步骤。

为了使用CSE基础服务，还需要开发者拥有华为云账号，可以登陆[http://www.huaweicloud.com/](http://www.huaweicloud.com/) 免费注册。建议开发者先通过CSE提供的“快速体验微服务能力”了解CSE，在下面的章节中，会省略体验过程中涉及到的一些公共操作，比如如何获取AK/SK认证信息等。

