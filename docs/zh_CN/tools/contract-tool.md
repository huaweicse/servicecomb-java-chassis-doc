## 概念阐述

本节介绍的契约开发工具是Swagger。

## Swagger介绍

Swagger是一种和语言无关的规范和框架，是一个API设计工具，用于定义服务接口，主要用于描述RESTful的API。它专注于为API创建优秀的文档和客户端库。

Swagger包括库、编辑器、代码生成器等很多部分，在Java Chassis框架中已经集成了Swagger库，同时在ServiceStage中提供了在线契约编辑的功能，这里主要介绍Swagger以下内容：

* Swagger API Spec，描述Rest API的语言。

* ServiceStage Swagger API Editor，ServiceStage上提供的Swagger API Spec的编辑器。

## Swagger API Spec

Swagger API Spec是Swagger用来描述Rest API的语言，可以使用yaml或json来表示。Swagger API Spec包含以下部分：

* swagger，指定swagger spec版本，2.0

* info，提供API的元数据

* basePath，相对于host的路径

* schemes，API的传输协议，http，https，ws，wss

* consumes，API可以消费的MIME类型列表

* produces，API产生的MIME类型列表

* paths，API的路径，以及每个路径的HTTP方法，一个路径加上一个HTTP方法构成了一个操作。每个操作都有以下内容：

  * tags，操作的标签

  * description，描述

  * externalDocs，外部文档

  * operationId，标识操作的唯一字符串

  * consumes，MIME类型列表

  * produces，MIME类型列表

  * parameters，参数列表，参数的描述包括：

    * name，名字

    * description，描述required，是否必须

    * in，参数获取的位置，包括如下几种：

      * Path、Query、Header、Body、Form

      * （对于Body类型的参数）

        * schema，数据类型，可以详细描述，也可以引用definition部分定义的schema

      * （对于Body类型以外的参数）

        * type，类型

        * format，数据格式

        * allowEmptyValue，是否允许空值

        * items，对于Array类型

        * collectionFormat，对于Array类型

        * default，缺省值

  * responses，应答状态码和对于的消息的Schema

  * schemes，传输协议

  * deprecated，不推荐使用

  * security，安全

* definitions，定义API消费或生产的数据类型，使用json-schema描述，操作的parameter和response部分可以通过引用的方式使用definitions部分定义的schema

Swagger API Spec对Rest API的每一个操作的请求消息的参数（Path,Query,Body,Form），响应消息的状态码和消息体的json结构都进行了详细的描述。如果需要查看详细的Swagger API Spec定义，请参考[http://swagger.io/specification/](http://swagger.io/specification/)。

## ServiceStage API Editor

ServiceStage提供了在线的Swagger API Editor，链接是[ServiceStage API Editor](https://servicestage.hwclouds.com/codegen/)，需要事先注册和登录华为云账号。

ServiceStage API Editor是Swagger API Spec的编辑器，Swagger API Spec支持两种文件格式，yaml和json，在ServiceStage API Editor中使用yaml或者json格式中进行编辑，同时允许下载两种格式的文件。在yaml编辑器的右面有所见即所得的预览。![](/start/契约开发工具.png)

ServiceStage API Editor页面的文件菜单提供了以下功能：

* File，文档下载

> * Download YAML，下载yaml格式的契约文件。
>
> * Download JSON，下载json格式的契约文件。

* Edit

> Convert to YAML，将json格式的契约定义转换成yaml格式。

* Generate-Document

> HTML，生成描述api的html文档。



