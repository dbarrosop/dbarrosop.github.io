---
title: GoBGP
date: "2017-04-18T18:00:00+02:00"
tags: [ bgp, automation, networking ]
---

For those that haven't heard about it yet, [GoBGP][gobgp] is, as they say _"an open source BGP implementation designed from scratch for modern environment and implemented in a modern programming language, the Go Programming Language"_.

To me, the most interesting part of GoBGP is that it uses a [grpc][grpc] interface to interact with the daemon and anything that can be done via its configuration file and/or CLI can be done via this interface. As a matter of fact, the CLI actually uses this interface to retrieve data and configure things.

<!--more-->

What this means is that you can easily write tooling to automatically deploy GoBGP instances, peers, policies or even to manipulate the RIB. The latter is particularly interesting as I haven't seen any other BGP daemon that let's you manipulate the RIB programmatically.

Last weekend I wanted to see how much of what I just said was true (spoiler alert, it is) so I put together a docker environment and wrote some code to:

* Deploy peers
* Deploy BGP policies
* Manipulate the RIB

Well, I don't want to waste more of your time so I will just link the Github repo where you can find the code, the environment and instructions to replicate everything:

* [https://github.com/dbarrosop/gobgp-grpc-demo][gobgp-grpc-demo]

[gobgp]: https://github.com/osrg/gobgp
[grpc]: http://www.grpc.io/
[gobgp-grpc-demo]: https://github.com/dbarrosop/gobgp-grpc-demo
