---
title: napalm-yang has been abandoned
subtitle: :(
categories: blog
tags: [ networking , automation ]
---

It's with sadness that I announce that [napalm-yang](https://github.com/napalm-automation/napalm-yang) is officially abandoned. It's a strange feeling to abandon a project, specially one that some people may be relying on, but that's always a risk in the opensource world. If you are a napalm-yang user or were planning to use it there are two paths for you right now:

1. Fork the project. I encourage you to do so if you feel that's the best course of action for you. I will try to support you as best as possible and direct new and existing users to your fork.
2. Migrate to [yangify](https://github.com/networktocode/yangify) and other related projects that will be released soon.

My recommended path would be to go yangify for a few reasons. First, it replaces [pyangbind](https://github.com/robshakir/pyangbind) with [yangson](https://pypi.org/project/yangson/). This brings some memory and CPU efficiencies and makes the project simpler to maintain as there is no need for bindings. This doesn't mean you can't use bindings, it just makes it optional.

More importantly, it replaces the custom DSL with a python framework. This brings a list of advantages:

1. Less code to maintain as there is no need to translate the DSL to actual python code
2. Orders of magnitude faster as there is no need to go back and forth between the DSL and the python code
3. More flexibility as there is so much you can express with a DSL.

Don't hesitate to contact me directly if you are concerned about this announcement or if you want help migrating to [yangify](https://github.com/networktocode/yangify) or forking [napalm-yang](https://github.com/napalm-automation/napalm-yang).
