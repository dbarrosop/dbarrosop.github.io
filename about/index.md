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
        url: https://napalm.readthedocs.io/en/latest/tutorials/first_steps_config.html
    videos:
      - description: NANOG64 presentation
        url: https://youtu.be/93q-dHC0u0I
    audios: []
  - name: S.I.R.
    description: SDN Internet Router.
    url: https://github.com/dbarrosop/sir
    links:
      - description: Documentation, features, architecture, use cases...
        url: https://sdn-internet-router-sir.readthedocs.io/en/latest/index.html
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
        url: https://pyfg.readthedocs.io/en/latest/first_steps.html
    videos: []
    audios: []
---

## Me

Feel free to check my [linkedin][linkedin] profile for information about my professional trajectory.

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
