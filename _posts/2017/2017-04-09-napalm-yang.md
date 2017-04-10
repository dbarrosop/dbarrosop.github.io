---
title: napalm-yang
subtitle:
categories: blog
tags: [ ops, automation, networking, napalm ]
---

It's been quite some time since my last blog post and, truth be told, I don't have that much time to blog as I am quite busy with work, [`napalm`][napalm] and life in general. However, I wanted to take a few minutes today to announce [`napalm-yang`][napalm_yang].

In summary, [`napalm-yang`][napalm_yang] tries to bring support for [`YANG`][yang] models to devices where:

1. There is no support for models at all
2. There is some limited support as models may evolve quicker than vendors

<!--more-->

I don't want to take your time with this blog post so just let me give you a few links in case you want to know more:

* [`napalm-yang`][napalm_yang] repo
* [Documentation][rtd] and a [tutorial][tutorial]
* [Slides][slides] and [video][video] of my presentation at the [SDN and Network Programmability Meetup in Barcelona][sdn_meetup] (don't miss the other two presentations, they were great)

Hope you find it useful and, as always, feedback is welcome.

[napalm]: https://github.com/napalm-automation/napalm
[napalm_yang]: https://github.com/napalm-automation/napalm-yang
[rtd]: https://napalm.readthedocs.io/en/latest/YANG/index.html
[sdn_meetup]: https://www.meetup.com/SDN-and-Network-Programmability-Meetup-in-Barcelona/
[slides]: https://www.dravetech.com/presos/i_love_the_smell_of_oc_in_the_morning/index.html
[tutorial]: https://github.com/napalm-automation/napalm-yang/blob/develop/interactive_demo/tutorial.ipynb
[video]: https://www.youtube.com/watch?v=EEpUWieTr40
[yang]: https://tools.ietf.org/html/rfc6020
