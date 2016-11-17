# elastic-saltstack
A SaltStack formula to deploy Elastic Stack 5 on one or more servers.

Requires the following pillar settings:

## Elasticsearch
```yaml
elk_cluster_name: my-elasticsearch-cluster
elasticsearch_servers: ["server01.example.com", "server02.example.com"]
```

## Kibana
The first hostname is also used as part of the certificate name for Nginx
```yaml 
kibana_fqdn: ['kibana.example.com', 'kibana', 'server03.example.com', 'example']
```

## Logstash
No settings required. Deployment of configuration (i.e. `/etc/logstash`) is handled separately from SaltStack.

TODO: automate node settings, e.g.
```bash
curl -XPUT 'localhost:9200/_template/logstash?pretty' -d'
{
  "template": "logstash*",
  "settings": {
    "number_of_shards": 1,
    "number_of_replicas": 0
  }
}'
```
