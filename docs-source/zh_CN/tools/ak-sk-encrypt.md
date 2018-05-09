## 概念阐述

本节介绍的AK/SK加密存储是基于共享秘钥的AES256加解密存储方案，通过工具生成秘钥物料，然后使用工具利用秘钥文件对指定的明文进行加密。例如可以使用这种方法对数据库密码进行加密，使用的时候再使用CSE SDK接口进行解密。

## AK/SK存储方案

AK/SK认证依赖用户配置的AK/SK，CSE默认支持自定义配置，用户可以自己实现解密接口，也可以使用CSE默认提供的机制。CSE内部默认提供明文和安全两种实现机制，下面分别来介绍下三种方式的配置方法。

1、明文方法，在microservice.yaml文件中增加配置

```
  cse:  
    credentials:
    accessKey: yourak
    secretKey: yoursk
    akskCustomCipher: default
```

2、密文方式，在microservice.yaml文件中增加配置

```
cse:
  credentials:
    accessKey: yourak  #明文
    secretKey: yoursk  #密文
    akskCustomCipher: security
```

默认提供的安全存储中，ak是不进行加密的。**读取cipher的时候，会优先读取CIPHER\_ROOT下面的certificate.yaml配置，参考AK/SK安全存储详细操作步骤**

3、自定义实现，首先自己实现一个接口com.huawei.paas.foundation.auth.credentials.AKSKCipher，里面有两个方法：

String name\(\);

这个是解密实现的名称定义，需要配置在配置文件中

char\[\] decode\(TYPE type, char\[\] encrypted\);

解密接口，TYPE表示ak还是sk，因为两者可能实现不一样的加密方式。

在microservice.yaml文件中增加配置

```
cse:
  credentials:
    accessKey: yourak  #对应的加解密后的ak
    secretKey: yoursk  #对应的加解密后的sk
    akskCustomCipher: youciphername  #实现类里面的name()方法返回的名称
```

再添加接口的SPI声明，在src/main/resources/META-INF/services新建一个文件com.huawei.paas.foundation.auth.credentials.AKSKCipher，内容为自己的实现类类名，例如：com.huawei.paas.cse.demo.pojo.client.CustomAKSKDepl

## AK/SK安全存储详细操作步骤

1、下载加解密工具，提供windowns和linux两个版本

2、使用加解密工具生成物料，使用命令keytool gen -a yourak -s yoursk命令，会在当前目录下生成root.key、common\_shared.key，和certificate.yaml文件，详细说明可以查看工具的帮助keytool gen -h

3、拷贝root.key、common\_shared.key、certificate.yaml到环境中，建议放到/opt/CSE/etc/cipher，本地调试的时候可以放到任意目录，所有需要部署微服务的节点都需要。如果是容器化部署，还需要挂载卷到指定目录。

4、启动应用，在启动应用之前需要先设置一个环境变量CIPHER\_ROOT，就是第四步复制凭证文件所在的目录

5、查看CSE控制台面板，服务是否注册成功，也可以查看应用启动日志，是否有服务注册成功日志

