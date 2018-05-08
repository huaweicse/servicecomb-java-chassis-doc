## 概念阐述

本节介绍如何在Maven插件方式下使用CSE-Codegen。

## 使用方法

### 插件的获取

1. 进入微服务引擎页面。
2. 在“微服务开发 &gt; 工具下载”页面获取CSE-SDK JAVA的依赖包，然后解压到本地Maven库中。

### 插件的使用

首先准备好一个API spec文件，该文件可以是json格式，或yaml格式，然后在pom.xml中增加插件配置，如下：

```
<plugin>
    <groupId>io.swagger</groupId>
    <artifactId>huawei-swagger-codegen-maven-plugin</artifactId>
    <version>2.2.2</version>
    <executions>
        <execution>
            <goals>
                <goal>generate</goal>
            </goals>
        </execution>
    </executions>
    <configuration>
        <skipOverwrite>true</skipOverwrite>
        <!-- generateAll or generateInterface -->
        <generateLevel>generateAll</generateLevel>
        <!-- specify the swagger yaml -->
        <inputSpecs>
            <param>./yaml/swagger.yaml</param>
        </inputSpecs>
        <groupId>com.huawei.paas.cse.demo</groupId>
        <artifactId>cse-test</artifactId>
        <artifactVersion>1.0.0</artifactVersion>
        <output>target/swagger</output>
        <serviceName>yami</serviceName>
        <cseVersion>2.1.35</cseVersion>
        <!-- target to generate -->
        <!--CSE-Java (JAX-RS)  | CSE-Java (SpringMVC) | CSE-Java (POJO) -->
        <language>CSE-Java (JAX-RS)</language>
    </configuration>
</plugin>
```

**说明：**

1、其中inputSpecs表示输入的spec api文件，可使用相对路径，支持多schema文件，文件名将作为本契约的schemaId，如

```
</inputSpecs>
    <param>./yaml/schema1.yaml</param>
    <param>./yaml/schema2.yaml</param>
</inputSpecs>
```

2、language指定生成目标目标代码类型，生成不同的开发模式，当前支持的目标代码类型有：

CSE-Java \(JAX-RS\)         JAX-RS开发模式

CSE-Java \(SpringMVC\)  SpringMVC开发模式

CSE-Java \(POJO\)            透明RPC开发模式

如：

&lt;language&gt;CSE-Java \(JAX-RS\)&lt;/language&gt;

3、output表示输出路径

4、skipOverwrite表示是否覆盖已经存在的文件

5、generateLevel表示生成的形式，支持两种generateAll 和generateInterface，generateAll表示生成全量工程，generateInterface表示只生成接口定义文件，例如SpringMVC模式，只生成RequestMapping文件。通常最开始的时候需要生成全量工程，后面开发过程中，新增加一个契约文件时，只需要生成接口即可。

6、serviceName 微服务名称，体现在microservice.yaml文件里面。

7、cseVersion CSE微服务版本号。

8、groupId artifactId artifactVersion，这三个参数均对应maven工程的坐标。

执行以下命令：

mvn generate-sources

根据配置的output路径，例如：&lt;output&gt;target/swagger&lt;/output&gt;，代码会生成在当前项目target/swagger目录下。

##### 



