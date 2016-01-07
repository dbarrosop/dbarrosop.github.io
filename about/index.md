---
title: David Barroso
subtitle: Network Engineer
category: about

projects:
  - name: NAPALM
    description: Network Automation and Programmability Abstraction Layer with Multivendor support.
    url: https://github.com/napalm-automation/napalm
    links:
      - description: First Steps with NAPALM
        url: http://napalm.readthedocs.org/en/latest/tutorials/first_steps_config.html
    videos:
      - description: NANOG64 presentation
        url: https://youtu.be/93q-dHC0u0I
    audios: []
  - name: S.I.R.
    description: SDN Internet Router.
    url: https://github.com/dbarrosop/sir
    links:
      - description: Documentation, features, architecture, use cases...
        url: http://sdn-internet-router-sir.readthedocs.org/en/latest/index.html
    videos:
      - description: Video proof of concept
        url: https://youtu.be/o1njanXhQqM
    audios:
      - description: SDN Internet Router Spotify on Software Gone Wild
        url: http://blog.ipspace.net/2015/01/sdn-router-spotify-on-software-gone-wild.html
      - description: SDN Internet Router is in production on Software Gone Wild
        url: http://blog.ipspace.net/2015/10/sdn-internet-router-is-in-production-on.html
  - name: pyfg
    description: API for FortiOS or how to turn FortiOS into JunOS.
    url: https://github.com/spotify/pyfg
    links:
      - description: First Steps with pyfg
        url: http://pyfg.readthedocs.org/en/latest/first_steps.html
    videos: []
    audios: []
---

## Me

I am a network engineer solving large-scale networking problems fast and smart. How? By combining the best practices in the fields of network, systems and software engineering. Although most of my experience is around networking (Service Provider, Datacenter and CDN) I also worked in my early days as an IT consultant dealing with all sort of crap (network and systems administratio) and even as a software engineer for a brief period of time.

I don't claim to be an expert on Linux administration or a senior software engineer but I am a seasoned network engineer that has had his share of suffering on different IT fields. This certainly gives me some perspective as most of the problems that we are facing in the networking field are not unique and have already been solved by others:

 * Zero touch provisioning ✔
 * Configuration management ✔
 * Version control ✔
 * Continuous Integration ✔
 * Application Integration ✔

Feel free to check my [linkedin][linkedin] profile for more information.

### Projects

{% for project in page.projects %}

#### [{{project.name}}]({{project.url}})

{{ project.description }}

{% for link in project.links %} * [<i class="fa fa-book"></i> {{link.description}}]({{link.url}})
{% endfor %}{% for video in project.videos %} * [<i class="fa fa-youtube-play"></i> {{video.description}}]({{video.url}})
{% endfor %}{% for audio in project.audios %} * [<i class="fa fa-headphones"></i> {{audio.description}}]({{audio.url}})
{% endfor %}

{% endfor %}

#### [Others][github]

For other interesting projects I have been working on better check my [github][github] profile.

[linkedin]: https://www.linkedin.com/in/dbarrosop
[github]: https://github.com/dbarrosop
