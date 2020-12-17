# 在本地（mac）环境安装 ELK

ELK = Elasticsearch（实时的分布式搜索和分析引擎） + Logstash（数据收集引擎） + Kibana（可视化 web 平台）;
node 打点服务提供数据；

## 部署 Elasticsearch

使用 homebrew 安装：`brew install elasticsearch`；

安装完毕之后，执行 `elasticsearch` 或 `brew services start elasticsearch` 启动 elasticsearch 服务，

访问端口`localhost:9200`，获得如下返回数据，说明安装完毕：

```json
{
  "name": "zhisongdeMacBook-Pro.local",
  "cluster_name": "elasticsearch_brew",
  "cluster_uuid": "slTqfyueTB2d7-iCjS-5GA",
  "version": {
    "number": "7.8.1-SNAPSHOT",
    "build_flavor": "oss",
    "build_type": "tar",
    "build_hash": "unknown",
    "build_date": "2020-07-31T16:57:12.889003Z",
    "build_snapshot": true,
    "lucene_version": "8.5.1",
    "minimum_wire_compatibility_version": "6.8.0",
    "minimum_index_compatibility_version": "6.0.0-beta1"
  },
  "tagline": "You Know, for Search"
}
```

## 部署 Kibana

同样的，执行下面指令部署和启动 Logstash:

```bash
brew install kibana

kibana
# or
brew services start kibana
```

访问 `localhost:5601` 即可看到 kibana 页面（需要 Elasticsearch 服务启动）；

## 部署 Logstash

同样的，执行下面指令部署和启动 Logstash:

```bash
brew install logstash

logstash
# or
brew services start logstash
```

logstash 在本地启动，需要指定配置文件：

```bash
# test_logstash.conf
input {
   file {
      path => ["xxx/local.txt"] # 创建并指定一个或多个txt作为log数据源
    }
  }
 output {
   elasticsearch{
      hosts => ["http://localhost:9200"]
      index => "local_logstash"
   }
}
```

在本地启动 logstash: `logstash -f ./test_logstash.conf`

访问 `localhost:9600` 即可看到 logstash 页面（需要 Elasticsearch 服务启动）；

## 搭建 node 打点服务

1. 使用 log4js 写入 log 数据

log 信息需要分类、分级；log 文件需要限制大小以及储存时间。log4js 非常合适这些需求。

大致思路：

- 设置信息等级，在 levels 中配置；
- 设置信息分类，在 categories 中配置；
- 设置信息输出类型、写入文件地址、文件限制大小、备份数量，在 appenders 中配置；
- 根据请求入参，选择合适的 log 方法；

贴一段 koa2 中 log4js 的配置仅供参考：

```js
const path = require('path')
const log4js = require('log4js')

const logPath = path.resolve(__dirname, '../elk-log')
const log4jsConfig = {
  levels: {
    debug: {
      value: 1,
      colour: 'black'
    },
    info: {
      value: 2,
      colour: 'black'
    },
    warn: {
      value: 3,
      colour: 'yellow'
    },
    error: {
      value: 4,
      colour: 'red'
    },
    fatal: {
      value: 5,
      colour: 'red'
    }
  },
  // pm2: true,
  appenders: {
    out: { type: 'stdout' },
    default: {
      type: 'dateFile',
      filename: logPath + '/default.txt',
      maxLogSize: 1024 * 1024 * 128, // 128M
      backups: 100
    },
    dev: {
      type: 'dateFile',
      filename: logPath + '/dev.txt',
      maxLogSize: 1024 * 1024 * 128,
      backups: 100
    },
    sit: {
      type: 'dateFile',
      filename: logPath + '/sit.txt',
      maxLogSize: 1024 * 1024 * 128,
      backups: 100
    },
    uat: {
      type: 'dateFile',
      filename: logPath + '/uat.txt',
      maxLogSize: 1024 * 1024 * 128,
      backups: 100
    }
  },
  categories: {
    default: {
      appenders: ['out', 'default'],
      level: 'all'
    },
    dev: {
      appenders: ['out', 'dev'],
      level: 'all'
    },
    sit: {
      appenders: ['out', 'sit'],
      level: 'all'
    },
    uat: {
      appenders: ['out', 'uat'],
      level: 'all'
    }
  }
}
log4js.configure(log4jsConfig)

const loggerMiddleware = async (ctx, next) => {
  await next()
  const logData = ctx.query
  // logData.type: 'debug' | 'info' | 'warn' | 'error' | 'fatal'
  // logData.env: 'dev' | 'sit' | 'uat'
  let type = ''
  if (logData.type && Object.keys(log4jsConfig.levels).includes(logData.type)) {
    type = logData.type
  } else {
    type = 'info'
  }
  const logger = log4js.getLogger(logData.env)
  const logText = `${JSON.stringify(logData)}`

  logger[type](logText)
}

module.exports = {
  loggerMiddleware
}
```

2. logstash 指定 log 文件夹

配置文件 path 参数修改为：

```bash
input {
   file {
      path => ["xxx/node-server/elk-log"] # 指定为log4js输出文件夹
    }
  }
 output {
   elasticsearch{
      hosts => ["http://localhost:9200"]
      index => "local_logstash"
   }
}
```

## 本地启动项目

启动 elk（mac，brew）:

```bash
#!/bin/bash
brew services start elasticsearch && brew services start kibana && brew services start logstash -f ./local_logstash.conf && logstash -f ./local_logstash.conf
```

然后启动 node 服务，即可在 Kibana 中查看 log 的数据了。

