## 概念阐述

两阶段提交协议是常见的一致性协议，许多分布式关系型数据管理系统采用此协议来完成分布式事务。它是协调所有分布式原子事务参与者，并决定提交或取消（回滚）的分布式算法。在两阶段提交协议中，包含了两种角色：协调者与参与者。参与者就是实际处理事务的节点，而协调者就是其中一台单独的进行分布式事务管理的节点。

## 场景描述

分布式强一致性是为了保证在服务调用完成时，各个参与事务的服务的状态已经保持一致。本节将以一个转账的例子来说明如何利用CSE的强一致性开发和设计分布式事务，保证事务参与方的数据强一致性。

## 开发示例

本示例以一个银行A,B之间进行转账的情景为例介绍强一致事务的开发。

* 前提条件：

  1. 运行服务的节点已经安装好mysql数据库，并创建指定的数据库（本例中为teststrong）

  2. 启动本地服务中心

  3. 启动事务协调器coordinator，可在demo-narayana模块中获取，直接运行RtsServer.java即可

* 事务发起方和参与方的POM中均需引入2PC事务对应的依赖包：

```xml
<dependency>
  <groupId>com.huawei.paas.cse</groupId>
  <artifactId>handler-2pc</artifactId>
</dependency>
```

* 在microservice.yaml中添加进处理链：

需在发起方的microservice.yaml文件中引入twoPC-consumer 的handler，用于在调用参与方时传输事务ID。

```yaml
cse:
  handler:
    chain:
      Consumer:
        default: loadbalance,twoPC-consumer,perf-stats
```

在参与方的microservice.yaml文件中引入twoPC-provider的handler，用于接收事务ID。

```
cse:
  handler:
    chain:
      Provider:
        default: twoPC-provider
```

* 配置JPA

在resource/META-INF/persistence.xml中配置JPA属性，连接mysql的配置样例如下：

```xml
<?xml version="1.0" encoding="UTF-8"?>
<persistence version="1.0" xmlns="http://java.sun.com/xml/ns/persistence" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://java.sun.com/xml/ns/persistence http://java.sun.com/xml/ns/persistence/persistence_1_0.xsd">
    <persistence-unit name="jta" transaction-type="JTA">
        <provider>org.hibernate.ejb.HibernatePersistence</provider>
        <jta-data-source>java:/mysqlDataSource</jta-data-source>
        <properties>
            <property name="hibernate.archive.autodetection" value="class"/>
            <property name="hibernate.hbm2ddl.auto" value="update"/>
            <property name="hibernate.current_session_context_class" value="jta"/>
            <property name="hibernate.dialect" value="org.hibernate.dialect.MySQL5Dialect"/>
            <property name="hibernate.connection.release_mode" value="after_statement"/>
        </properties>
    </persistence-unit>
</persistence>
```

其中的mysqlDataSource为下一节中配置的DataSource，persistence-unit name则会在entityManagerFactory中引用。

* 配置DataSource，Adaptor 及entitiyManager

在发起方的resource/META-INF/spring/\*.bean.xml 文件中进行配置，样例如下：

```xml
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
       xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
       xmlns:tx="http://www.springframework.org/schema/tx"
       xmlns:context="http://www.springframework.org/schema/context"
       xmlns:jpa="http://www.springframework.org/schema/data/jpa"
       xsi:schemaLocation="http://www.springframework.org/schema/beans http://www.springframework.org/schema/beans/spring-beans-4.1.xsd
            http://www.springframework.org/schema/tx http://www.springframework.org/schema/tx/spring-tx-4.1.xsd http://www.springframework.org/schema/data/jpa http://www.springframework.org/schema/data/jpa/spring-jpa.xsd
            http://www.springframework.org/schema/context
            http://www.springframework.org/schema/context/spring-context-4.0.xsd">
    <tx:annotation-driven/>
    <context:component-scan base-package="narayana"/>

    <jpa:repositories base-package="narayana.jpamodel"/>

    <bean id="mysqlDataSource" class="org.apache.commons.dbcp2.managed.BasicManagedDataSource"
          destroy-method="close">
        <property name="xaDataSourceInstance">
            <bean class="com.mysql.jdbc.jdbc2.optional.MysqlXADataSource">
                <property name="url" value="jdbc:mysql://localhost:3306/bank1?user=root&amp;password=root"/>
            </bean>
        </property>
        <property name="driverClassName" value="com.mysql.jdbc.Driver"/>
        <property name="transactionManager" ref="transactionManagerImpl"/>
        <property name="url" value="jdbc:mysql://localhost:3306/bank1?user=root&amp;password=root"/>
    </bean>


    <bean id="jpaVendorAdapter" class="org.springframework.orm.jpa.vendor.HibernateJpaVendorAdapter">
        <!--<property name="showSql" value="true"/>-->
        <property name="generateDdl" value="true"/>
        <property name="database" value="MYSQL"/>
    </bean>

    <bean id="entityManagerFactory" class="org.springframework.orm.jpa.LocalContainerEntityManagerFactoryBean">
        <property name="dataSource" ref="mysqlDataSource"/>
        <property name="jpaVendorAdapter" ref="jpaVendorAdapter"/>
        <property name="persistenceUnitName" value="jta"/>
        <property name="packagesToScan" value="narayana.jpamodel"/>
    </bean>

</beans>
```

其中的数据库bank1表示银行A的账户系统。参与方配置类似，只是连接不同的数据库bank2，表示银行B的账户系统。

## 示例代码

* Model定义

采用JPA注解方式定义表结构，@Table中的name即为表名，该表建立在datasource中的定义的数据库中。

```java
@Entity
@Table(name="account")
public class Account {
    @Id
    @GeneratedValue(strategy = IDENTITY)
    private Long id;

    private String username;

    private Long money;

    public Account() {
    }

    public Account(String username, Long money) {
        this.username = username;
        this.money = money;
    }

    public void setMoney(Long money) {
        this.money = money;
    }

    public Long getId() {
        return id;
    }

    public String getUsername() {
        return username;
    }

    public Long getMoney() {
        return money;
    }
}
```

* Repository及Service定义

AccountService 和AccountRepository 都会根据xml配置自动注入。

```java
public interface AccountRepository extends JpaRepository<Account, Long> {
    List<Account> findByUsername(String name);
}
```

```java
@Service
@Transactional
public class AccountService {

    private final AccountRepository accountRepository;

    @Autowired
    public AccountService(AccountRepository accountRepository) {
        this.accountRepository = accountRepository;
    }

    public Account save(String username, Long money) {
        return this.accountRepository.save(new Account(username, money));
    }

    public void update(Account account) {
        this.accountRepository.save(account);
    }

    public void delete(Long id) {
        this.accountRepository.delete(id);
    }

    public List<Account> findByName(String name){
        return this.accountRepository.findByUsername(name);
    }
}
```

* 发起方服务开发

引入 @Transactional注解，配置回滚条件和传播策略，即可自动创建事务并保证分布式一致性。服务的业务逻辑中的数据操作通过AccountService 完成。

```java
    @Autowired
    private AccountService accountService;

    @Path("/transfer/{from}")
    @GET
    @Transactional(rollbackFor = Exception.class, propagation = Propagation.REQUIRED)
    public String transfer(@PathParam("from") String from, @QueryParam("username") String username,
                                @QueryParam("money") long money) throws Exception {
        List<Account> accounts = accountService.findByName(from);
        if(accounts.size() == 0) {
            accountService.save(from, 20000L);
            LOGGER.warn("This account is not present!");
            return "This account is not present";
        }

        Account account = accounts.get(0);
        if(account.getMoney() < money) {
            LOGGER.warn("There is no enough money!");
            return "There is no enough money";
        }

        RestTemplate restTemplate = RestTemplateBuilder.create();
        String str = restTemplate.getForObject("cse://demo-narayana-jaxrs2/bank2/transfer/" + username
                + "?amount=" + money, String.class);

        account.setMoney(account.getMoney() - money);
        accountService.update(account);

        return str;
    }
```

* 参与方服务开发

本demo中Model，Service 和Repository均与发起方一致。参与方的方法上方加@Transactionl注解可以同发起方创建的事务绑定为同一个事务，由框架保证它们的一致性。

```java
    @Autowired
    private AccountService accountService;

    @Path("/transfer/{name}")
    @GET
    @Transactional(rollbackFor = Exception.class, propagation = Propagation.REQUIRED)
    public String transfer(@PathParam("name") String name, @QueryParam("amount") long amount){
        List<Account> accounts = accountService.findByName(name);
        if(accounts.size() == 0) {
            accountService.save(name, amount);
            return name;
        }

        Account account = accounts.get(0);
        account.setMoney(account.getMoney() + amount);
        accountService.update(account);

        return  name;
    }
```



