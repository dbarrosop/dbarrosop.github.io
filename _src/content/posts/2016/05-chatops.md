---
title: "ChatOps Demo for Networking"
date: "2016-03-30T18:00:00+02:00"
tags: [ ops, automation, networking ]
---

I have been working on a project to automate all things network related. Not only provisioning new
stuff but operations as well. I am not going to tell you about the benefits of automation, everybody should know by now.

However, when talking about operations it is important to note that **not all operations can be
automated but all operations can be abstracted**. What I mean with that is that if you are
peering with someone you still have to perform some action so your system knows who the new peer
is, their IP address, their AS and where are you going to peer with them. However, the operator
doesn't need to know that it has to go to the inventory system to add the new peer, then go to the
IPAM system to insert the required information and finally configuring the peer on the router. You
could abstract that entire repetitive and error prone workflow with a single command: `add peer
in=bma ip=10.0.0.1 as=65100`.


<!--more-->

## Demo

As I was exploring how to do operations better ensuring consistency and keeping everybody in the
loop I realized that chatops was the answer. So I started working on a simple proof of concept.

1. Operations are performed via `ansible` + `napalm`.
2. Details of `ansible` are abstracted by Python ``invoke``.
3. `Stackstorm` allows operators to fire ``invoke`` tasks from slack.
4. Devices can report critical changes to operators on slack via `stackstorm`.


{{< youtube JQimPMpV0To >}}

{{<box class="bs-callout bs-callout-info">}}
I will be sharing the code for the demo very soon. Stay tuned : )
{{</box>}}

The example is very simple, I was just trying to prove the feasibility and the value. As I see it,
these are the main benefits:

1. Changes are standardized. If you are an operator you can only perform changes that are exposed to
you.
2. Everybody is in the loop. You are doing your job on a specific slack channel which means
everybody knows what you are up to. Something broke 30 minutes ago? Let's just scroll up the slack
channel and see if someone did some change then.
3. Operators are notified by switches almost instantly about critical events on slack. Why keep
switching between mail, pager, slack, the terminal, etc.? That's just overhead.

## FAQ

Some common questions I got :)

1. **Why `ansible`? Why not use `stackstorm` directly?**

    Main reason was to be able to perform operations even in the event of stackstorm being down, unreachable,
etc. It's also an interesting framework for operations used by many people so using `ansible` will
save a lot of work as we can reuse other's people code and contribute back.

2. **Why abstract playbooks with ``invoke``?**

    We care about operations, not about playbooks. By abstracting `ansible` with ``invoke`` tasks we
can change playbooks and restructure things later on without impacting operations.

3. **Why are the examples so simple?**

    It's just a proof of concept so I build something simple that everybody in the networking world could
relate to.

## Links

* [napalm][napalm]
* [ansible][ansible]
* [invoke][invoke]
* [StackStorm][stackstorm]


[napalm]: https://github.com/napalm-automation/napalm
[ansible]: https://www.ansible.com/
[invoke]: http://www.pyinvoke.org/
[stackstorm]: https://stackstorm.com/
