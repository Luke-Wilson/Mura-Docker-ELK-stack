# Mura + ELK + Docker

#### Start up:

Then access the application via:

http://localhost:8888

To login type esc-l or go to http://localhost:8888/admin

```
Username:admin
Password:admin
```

#### MYSQL Connection Info:

```
Host: localhost
Port: 55555
Username: root
Passsword: NOT_SECURE_CHANGE
```

Simply hold down control-c to stop the service.

# Guide

## Step by step overview:

1. Get Mura running
2. Add Logstash config files
3. Create logstash service
4. Create elasticsearch service
5. Create a test HTTP log entry
6. Add the kibana service
7. Login to Kibana and map an index pattern to the myhttpindex
8. View your test HTTP logs in Kibana
9. Install Filebeat on Lucee server
10. Configure Filebeat
11. Run Filebeat
12. Create a mock Catalina log entry
13. Map an index pattern to the serverlog index
14. View your test serverlog entry in Kibana

###Get Mura running
The way you set this up may vary depending on your particular project. For my config, see the `mura` and `mura_mysql` services in `docker-compose.yml`

###Add Logstash config files
We'll create the following files locally, and then mount them into the `logstash` service:
.
└── logstash
├── config
| ├── logstash.yml
| └── pipelines.yml
└── pipelines
├── beats.conf
└── http.conf

###Create logstash service
In your docker-compose.yml, create a new service called "logstash":

You'll need to expose ports 8080 (so that logstash will accept HTTP log inputs) and 5044 (to accept filebeat log inputs).

You also need to mount your the config and pipeline files you created above into this container.

```
logstash:
	image: logstash:7.0.1
	depends_on: ['elasticsearch']
	expose:
		- "8080"
		- "5044"
	volumes:
		- ./logstash/config:/usr/share/logstash/config
		- ./logstash/pipelines:/usr/share/logstash/pipeline
```

###Create elasticsearch service
Since logstash will be sending its outputs to Elastic Search, we need to create a elasticsearch service.

We want to publish ports 9200 and 9300 so that we can access ES at http://localhost:9200

We also want to expose these ports to the other containers (I'm not sure if this step is redundant though.)

Lastly, we'll create a named volume "esdata01" so that our log data will persist outside the container.

```
elasticsearch:
	image: elasticsearch:7.0.1
	ports:
		- "9200:9200"
		- "9300:9300"
	expose:
		- "9200"
		- "9300"
	environment:
		discovery.type: single-node
	volumes:
		- esdata01:/usr/share/elasticsearch/data

# Don't forget to add esdata01 to your top-level volumes
volumes:
	esdata01:
		driver: local
```

###Create a test HTTP log entry

1. Start up the services using `docker-compose up`
2. Navigate to Mura at http://localhost:8888
3. Click the "Send log via HTTP to logstash:8080" link.
4. Check to see if your index in Elastic Search received a new document by checking the docs.count column for the myhttpindex-\* row

###Add the kibana service
Now that we are creating log entries, we can set up Kibana to explore these logs. Add the kibana service to `docker-compose.yml`

We need to publish port 5601 so that we can access Kibana at http://localhost:5601.

We also pass the ELASTICSEARCH_HOSTS environment variable, making sure to use the ES service name as the host name (i.e. "elasticsearch").

```
kibana:
	image: docker.elastic.co/kibana/kibana:7.0.1
	depends_on: ['elasticsearch']
	environment:
		SERVER_NAME: kibana
		ELASTICSEARCH_HOSTS: http://elasticsearch:9200
	ports:
		- "5601:5601"
	expose:
		- "5601"
```

###Login to Kibana and map an index pattern to the myhttpindex
http://localhost:5601

!["./img/createIndexPattern.png]
!["./img/configureTimestamp.png]

###View your test HTTP logs in Kibana

###Install Filebeat on Lucee server

###Configure Filebeat

###Run Filebeat

###Create a mock Catalina log entry

###Map an index pattern to the serverlog index

###View your test serverlog entry in Kibana
