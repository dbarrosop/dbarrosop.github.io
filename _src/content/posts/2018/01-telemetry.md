---
title: Network telemetry
date: "2018-05-22T18:00:00+02:00"
tags: [ monitoring, networking ]
---
Whether you just don't like SNMP or you want to leverage the same tooling for monitoring and alerting as the rest of your organization, this "tutorial" has you covered. What we are going to do is see how we can monitor our network infrastructure with prometheus and grafana.

In this blogpost we are going to see how to build a webapp using flask+nornir that gathers metrics from the network and presents it via a web application. Then we will scrape that web application with prometheus to store those metrics and finally we will see how we can present those metrics with grafana. In summary, you will learn how to replace your old-fashioned SNMP monitoring system with a next-generation-12-factor-app-compliant-telemetry-system.

[Continue reading on github](https://github.com/dravetech/blogposts-demos/tree/master/network-telemetry-prometheus#network-telemetry-from-snmp-to-prometheus)
