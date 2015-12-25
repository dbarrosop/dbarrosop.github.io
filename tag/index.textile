---
title: Tags
category: tag
---

<ul class="list-group">
{% for tag in site.data.tags %}
  <li class="list-group-item"><a href="{{ tag.name }}.html">{{ tag.name }}</a> <span class="badge">{{site.tags[tag.name] | size}}</span></br><em>{{ tag.description }}</em></li>
{% endfor %}
</ul>
