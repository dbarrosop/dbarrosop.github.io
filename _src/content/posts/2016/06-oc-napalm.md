---
title: OpenConfig + NAPALM
date: "2016-05-06T18:00:00+02:00"
tags: [ ops, automation, networking, napalm ]
---

The other day I talked with [Rob Shakir][Rob Shakir] who has been working very closely with [OpenConfig][OpenConfig] and we came up with the idea of trying to add [OpenConfig][OpenConfig] support to [NAPALM][NAPALM].

The idea was that a network driver would translate unsupported models to native commands while
models supported by the device would be sent via native mechanisms (gRPC, NETCONF, etc.). That
would allow people to start using [OpenConfig][OpenConfig] as [NAPALM][NAPALM] would serve as
a transition mechanism.

So, after Rob sent me an example on how to use [pyangbind][pyangbind], which he also wrote by
the way, I put together a [POC][POC]. It is very cool to see that thanks to [pyangbind][pyangbind]
adding [OpenConfig][OpenConfig] to NAPALM was really a piece of cake. Open Source for the win!

<!--more-->

It would be interesting to be able to retrieve information from the device using
[OpenConfig][OpenConfig] models as well but I will leave that for a future exercise. In the
meantime, you can see below an example on how to use [OpenConfig][OpenConfig] with [NAPALM][NAPALM]
to configure a device:

```python
>>> from napalm_base import get_network_driver
>>> driver = get_network_driver('eos')
>>> optional_args = {'port': 12443,}
>>>
>>> d = driver('localhost', 'vagrant', 'vagrant', optional_args=optional_args)
>>> d.open()
>>>
>>> with open('bgp_global.json', 'r') as f:
...     data = f.read()
...
>>> print(data)
{
    "openconfig-bgp:bgp": {
        "neighbors": {
            "neighbor": [
                {
                    "ebgp-multihop": {
                        "config": {
                            "enabled": true,
                            "multihop-ttl": 255
                        }
                    },
                    "neighbor-address": "2001:db8::1",
                    "config": {
                        "neighbor-address": "2001:db8::1",
                        "peer-as": 6643,
                        "description": ":a=6643:d=Jive:"
                    },
                    "afi-safis": {
                        "afi-safi": [
                            {
                                "config": {
                                    "enabled": true,
                                    "afi-safi-name": "openconfig-bgp-types:IPV6_UNICAST"
                                },
                                "afi-safi-name": "IPV6_UNICAST"
                            }
                        ]
                    }
                },
                {
                    "neighbor-address": "192.0.2.2",
                    "config": {
                        "neighbor-address": "192.0.2.2",
                        "peer-as": 54113,
                        "description": ":a=54413:d=Fastly:"
                    },
                    "afi-safis": {
                        "afi-safi": [
                            {
                                "config": {
                                    "enabled": true,
                                    "afi-safi-name": "openconfig-bgp-types:IPV6_UNICAST"
                                },
                                "afi-safi-name": "IPV6_UNICAST"
                            },
                            {
                                "config": {
                                    "enabled": true,
                                    "afi-safi-name": "openconfig-bgp-types:IPV4_UNICAST"
                                },
                                "afi-safi-name": "IPV4_UNICAST"
                            }
                        ]
                    }
                }
            ]
        },
        "global": {
            "config": {
                "as": 6643,
                "router-id": "192.0.2.1"
            },
            "afi-safis": {
                "afi-safi": [
                    {
                        "use-multiple-paths": {
                            "ebgp": {
                                "config": {
                                    "maximum-paths": 8
                                }
                            }
                        },
                        "config": {
                            "enabled": true,
                            "afi-safi-name": "openconfig-bgp-types:IPV6_UNICAST"
                        },
                        "afi-safi-name": "IPV6_UNICAST"
                    },
                    {
                        "use-multiple-paths": {
                            "ebgp": {
                                "config": {
                                    "maximum-paths": 8
                                }
                            }
                        },
                        "config": {
                            "enabled": true,
                            "afi-safi-name": "openconfig-bgp-types:IPV4_UNICAST"
                        },
                        "afi-safi-name": "IPV4_UNICAST"
                    }
                ]
            }
        }
    }
}

>>> d.load_openconfig(model='openconfig_bgp', data=data)
>>> print d.compare_config()
@@ -26,7 +26,20 @@
 !
 no ip routing
 !
-router bgp 123
+router bgp 6643
+   maximum-paths 8
+   neighbor 192.0.2.2 remote-as 54113
+   neighbor 192.0.2.2 description :a=54413:d=Fastly:
+   neighbor 192.0.2.2 maximum-routes 12000
+   neighbor 2001:db8::1 remote-as 6643
+   neighbor 2001:db8::1 description :a=6643:d=Jive:
+   neighbor 2001:db8::1 maximum-routes 12000
+   address-family ipv4
+      neighbor 192.0.2.2 activate
+   !
+   address-family ipv6
+      neighbor 192.0.2.2 activate
+      neighbor 2001:db8::1 activate
 !
 management api http-commands
    no shutdown
>>> d.commit_config()
>>> d.load_openconfig(model='openconfig_bgp', data=data)
>>> print d.compare_config()
''
>>>
```

[NAPALM]: https://github.com/napalm-automation/napalm
[Rob Shakir]: http://rob.sh/
[OpenConfig]: http://www.openconfig.net/
[pyangbind]: https://github.com/robshakir/pyangbind
[POC]: https://github.com/napalm-automation/napalm-base/pull/28
