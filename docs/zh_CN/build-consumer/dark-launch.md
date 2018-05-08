## 场景描述

用户可以通过使用灰度发布，实现版本的平滑过渡升级。

## 注意事项

1. 若要使用灰度发布功能，需要微服务对接配置中心。

2. 灰度规则如果是自定义规则，那么匹配的参数可以是接口定义的参数，也可以是context参数。

   * 配置接口定义参数的示例代码如下：

     ```java
     // 服务接口
     public interface Compute {
        int add(int a, int b);
     }
     ```

     ```java
     // 调用服务
     @RpcReference(microserviceName = "hello", schemaId = "codeFirstCompute")
     public static Compute compute;

     public static void main(String[] args)
        throws Exception {
        Log4jUtils.init();
        BeanUtils.init();
        System.out.println("a=1, b=2, result=" + compute.add(1, 2));
     }
     ```

     灰度规则配置示例如下：

     ```yaml
     {
        "policyType": "RULE",
        "ruleItems": [
            {
                "groupName": "test",
                "groupCondition": "version=0.0.2",
                "policyCondition": "a<15"
            }
        ]
     }
     ```

     > **注意**：灰度规则中过滤的接口参数必须是在接口方法参数表中直接定义的，不能选择一个对象类型参数的某个字段做过滤。

   * 配置context参数的示例代码如下：

     ```java
     InvocationContext invocation = new InvocationContext();
     invocation.addContext("ta", "tvalue");
     ContextUtils.setInvocationContext(invocation);
     ```

     由于context参数只能是String类型的，所以相对应的自定义灰度规则只能过滤String类型的参数，示例如下

     ```yaml
      {
          "policyType": "RULE",
          "ruleItems": [
              {
                  "groupName": "test",
                  "groupCondition": "version=0.0.2",
                  "policyCondition": "ta~tva*"
              }
          ]
      }
     ```

## 配置说明

灰度发布功能需要配置maven依赖和在Consumer端配置负载均衡。

1. 增加依赖关系\(pom.xml\)

   ```xml
   <dependency>
       <groupId>com.huawei.paas.cse</groupId>
       <artifactId>cse-handler-cloud-extension</artifactId>
   </dependency>
   ```

2. 在Consumer端配置负载均衡\(microservice.yaml\)

   ```yaml
   cse: 
     loadbalance:
       serverListFilters: darklaunch
       serverListFilter:
         darklaunch:
           className: com.huawei.paas.darklaunch.DarklaunchServerListFilter
   ```

3. 添加服务依赖版本规则，就是consumer端对服务端依赖的版本范围。由于客户端默认只会下载最新版本的微服务实例，在启用灰度发布的时候，灰度规则默认只应用于最新版本，灰度发布的效果可能和实际的预期效果不同。如果一个微服务需要支持灰度发布，建议增加如下配置项：

   ```yaml
   cse:
     references:
       servicename:  # servicename是依赖的微服务的名称，下同
         version-rule: 0.0.1+
   ```

4. 配置灰度规则，在microservice.yaml文件中增加如下配置：

   ```yaml
   cse:
     darklaunch:
       policy:
         servicename: "{\"policyType\":\"RULE\",\"ruleItems\":[{\"groupName\":\"test\",\"groupCondition\":\"version=0.0.2\",\"policyCondition\":\"age<15\"}]}"
   ```

   灰度规则的内容本身是一个Json串，以上示例中的配置表示的含义是：一个名为test的灰度规则配置，将参数中age &lt; 15的请求发送给版本为0.0.2的微服务。灰度规则格式化后是这样的：

   ```yaml
   {
      "policyType": "RULE",
      "ruleItems": [
          {
              "groupName": "test",
              "groupCondition": "version=0.0.2",
              "policyCondition": "age<15"
          }
      ]
   }
   ```

   各项配置含义如下：

   * policyType：有RULE/RATE两种取值。RULE表示自定义规则，RATE表示百分比权重
   * ruleItems：灰度规则配置项
   * groupName：灰度规则分组名称
   * groupCondition：灰度规则作用域，当前支持按版本号配置，表示此灰度规则适用于哪个版本的微服务。当灰度规则作用域包含多个版本号时，使用英文逗号分隔版本号，例如`"groupCondition": "version=0.0.2,0.0.1"`
   * policyCondition：灰度规则。如果policyType=RATE，则此配置项为一个数字，例如policyCondition=80表示流量有80%的概率流到此版本的微服务；如果policyType=RULE，则policyCondition填写自定义的规则，现在支持`=`、`>`、`<`、`~`（`~`表示模糊匹配，例如`name~a*`表示匹配所有name参数以a开头的值），如果是context参数，由于context参数都是string类型，所以这些操作符对应的是string操作

> **注意**：
>
> * 目前灰度发布的自定义策略，支持的数据类型只包含String和Integer。 使用灰度发布涉及业务提前规划，在做规划的时候，如果基于请求参数，请使用String或者Integer两种类型的参数。



