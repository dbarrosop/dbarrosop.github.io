---
title: Vagrant Introduction for network engineers
date: "2016-01-08T18:00:00+02:00"
tags: [ automation, networking ]
---

I don't want to spend too much time explaining what vagrant is so here is their own introduction:

> Vagrant provides easy to configure, reproducible, and portable work environments built on top of industry-standard technology and controlled by a single consistent workflow to help maximize the productivity and flexibility of you and your team.
>
> To achieve its magic, Vagrant stands on the shoulders of giants. Machines are provisioned on top of VirtualBox, VMware, AWS, or any other provider. Then, industry-standard provisioning tools such as shell scripts, Chef, or Puppet, can be used to automatically install and configure software on the machine.

<!--more-->

### Why Vagrant?

Vagrant allows you to define in a simple configuration file a virtual environment that you can `create`, `start`, `stop`, `destroy` with a single command on your CLI. As the environment is specified entirely in a file, or set of files, you can easily share it with colleagues.


For example, below is a development environment I created for [napalm][napalm]. This allows us to share the environment between all the developers so we all can run consistent tests while coding:

```ruby
# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|

  config.vm.define "base" do |base|
    base.vm.box = "hashicorp/precise64"

    base.vm.network :forwarded_port, guest: 22, host: 12200, id: 'ssh'

    base.vm.network "private_network", virtualbox__intnet: "link_1",
                                       ip: "10.0.1.100"
    base.vm.network "private_network", virtualbox__intnet: "link_2",
                                       ip: "10.0.2.100"

    base.vm.provision "shell", inline: <<-SHELL
      sudo apt-get update
      sudo apt-get install lldpd -y
    SHELL
  end

  config.vm.define "eos" do |eos|
    eos.vm.box = "vEOS-4.15.2F"

    eos.vm.network :forwarded_port, guest: 22, host: 12201, id: 'ssh'
    eos.vm.network :forwarded_port, guest: 443, host: 12443, id: 'https'

    eos.vm.network "private_network", virtualbox__intnet: "link_1",
                                      ip: "169.254.1.11", auto_config: false
    eos.vm.network "private_network", virtualbox__intnet: "link_2",
                                      ip: "169.254.1.11", auto_config: false

    eos.vm.provision "host_shell", inline: <<-SHELL
      ./provision.py eos 12443 vagrant vagrant
    SHELL

  end

  config.vm.define "iosxr" do |iosxr|
    iosxr.vm.box = "IOSXRv-5.3.0"

    iosxr.vm.network :forwarded_port, guest: 22, host: 12202, id: 'ssh'

    iosxr.vm.network "private_network", virtualbox__intnet: "link_1",
                                        ip: "169.254.1.11", auto_config: false
    iosxr.vm.network "private_network", virtualbox__intnet: "link_2",
                                        ip: "169.254.1.11", auto_config: false

    iosxr.vm.provision "host_shell", inline: <<-SHELL
      ./provision.py iosxr 12202 vagrant vagrant
    SHELL

  end

  config.vm.define "junos" do |junos|
    junos.vm.box = "juniper/ffp-12.1X47-D20.7-packetmode"

    junos.vm.network :forwarded_port, guest: 22, host: 12203, id: 'ssh'

    junos.vm.network "private_network", virtualbox__intnet: "link_1",
                                        ip: "169.254.1.11", auto_config: false
    junos.vm.network "private_network", virtualbox__intnet: "link_2",
                                        ip: "169.254.1.11", auto_config: false

    junos.vm.provision "host_shell", inline: <<-SHELL
      ./provision.py junos 12203 vagrant vagrant
    SHELL

  end

end
```

### Requirements

These are the requirements for using vagrant:

  * [Vagrant][vagrant].
  * [VirtualBox][virtualbox] or another supported [provider][providers].
  * [Boxes][boxes], either [publicly available][public_boxes] or created by you.

#### Boxes

Boxes are base images that can be used to instantiate the VMs that will comprise your environment. These are some of the boxes I think are more interesting for network engineers:

  * **hashicorp/precise64** - Standard Ubuntu (publicly available via hashicorp's repository)
  * **CumulusCommunity/cumulus-vx** - Cumulus Linux (publicly available via hashicorp's repository)
  * **juniper/ffp-12.1X47-D20.7-packetmode** - JunOS (publicly available via hashicorp's repository)
  * **vEOS-4.15.2F** - vEOS 4.15.2F (for instructions on how to install this box check [this][veos] post from Arista)
  * **IOSXRv-5.3.0** - I will blog on how to create this one.

Boxes that are publicly available can be installed with the command `vagrant box add $name`, where name is the name of the box, i.e.:

```
$ vagrant box add hashicorp/precise64
==> box: Loading metadata for box 'hashicorp/precise64'
    box: URL: https://atlas.hashicorp.com/hashicorp/precise64
This box can work with multiple providers! The providers that it
can work with are listed below. Please review the list and choose
the provider you will be working with.

1) hyperv
2) virtualbox
3) vmware_fusion

Enter your choice: 2
==> box: Adding box 'hashicorp/precise64' (v1.1.0) for provider: virtualbox
    box: Downloading: https://vagrantcloud.com/hashicorp/boxes/precise64/versions/1.1.0/providers/virtualbox.box
==> box: Successfully added box 'hashicorp/precise64' (v1.1.0) for 'virtualbox'!
```

You can check the ones you have available with `vagrant box list`:

```
$ vagrant box list
CumulusCommunity/cumulus-vx          (virtualbox, 2.5.3)
IOSXRv-5.3.0                         (virtualbox, 0)
hashicorp/precise64                  (virtualbox, 1.1.0)
juniper/ffp-12.1X47-D20.7-packetmode (virtualbox, 0.5.0)
vEOS-4.15.2F                         (virtualbox, 0)
```

### How does it work?

Assuming the previous `Vagranfile`, if I type `vagrant up` I will get a lab up and running with the following characteristics:

 * 4 VMs running 4 different operating systems: **Linux**, **vEOS**, **JunOS** and **IOS-XR**.
 * Each VM is going to have 3 NICs: a management interface, one connected to `link_1` and another one to `link_2`.
 * VMs will be provisioned automatically with some initial configuration as defined in the configuration file. I am using a script for this task that is triggered by the [`host_shell` provisioner][host_shell].
 * All the machines will be accessible via SSH and, in addition, vEOS will be accessible via the eAPI.

Once all the VMs have been started I can easily connect to them via SSH with the following command `vagrant ssh $name`, where name is the name of the VM, i.e., `vagrant ssh eos`.

You can also start or stop a subset of VMs easily by specifying them as a list. In the following example I am going to start the VMs running Linux (`base`) and vEOS (`eos`) only and then I am going to connect to them and check LLDP:


```
$ vagrant up base eos
Bringing machine 'base' up with 'virtualbox' provider...
Bringing machine 'eos' up with 'virtualbox' provider...
==> base: Importing base box 'hashicorp/precise64'...
==> base: Matching MAC address for NAT networking...
==> base: Checking if box 'hashicorp/precise64' is up to date...
==> base: Setting the name of the VM: vagrant_base_1450958942493_11667
==> base: Fixed port collision for 22 => 2222. Now on port 2200.
==> base: Clearing any previously set network interfaces...
==> base: Preparing network interfaces based on configuration...
    base: Adapter 1: nat
    base: Adapter 2: intnet
    base: Adapter 3: intnet
==> base: Forwarding ports...
    base: 22 => 2200 (adapter 1)
==> base: Booting VM...
==> base: Waiting for machine to boot. This may take a few minutes...
    base: SSH address: 127.0.0.1:2200
    base: SSH username: vagrant
    base: SSH auth method: private key
    base: Warning: Connection timeout. Retrying...
    base:
    base: Vagrant insecure key detected. Vagrant will automatically replace
    base: this with a newly generated keypair for better security.
    base:
    base: Inserting generated public key within guest...
    base: Removing insecure key from the guest if it's present...
    base: Key inserted! Disconnecting and reconnecting using new SSH key...
==> base: Machine booted and ready!
==> base: Checking for guest additions in VM...
    base: The guest additions on this VM do not match the installed version of
    base: VirtualBox! In most cases this is fine, but in rare cases it can
    base: prevent things such as shared folders from working properly. If you see
    base: shared folder errors, please make sure the guest additions within the
    base: virtual machine match the version of VirtualBox you have installed on
    base: your host and reload your VM.
    base:
    base: Guest Additions Version: 4.2.0
    base: VirtualBox Version: 5.0
==> base: Configuring and enabling network interfaces...
==> base: Mounting shared folders...
    base: /vagrant => /Users/dbarroso/Documents/workspace/spotify/napalm/test/unit/vagrant
==> base: Running provisioner: shell...
    base: Running: inline script
==> base: stdin: is not a tty
==> base: Get:1 http://security.ubuntu.com precise-security InRelease [54.5 kB]
==> base: Get:2 http://security.ubuntu.com precise-security/main Sources [138 kB]
==> base: Ign http://us.archive.ubuntu.com precise InRelease
==> base: Get:3 http://us.archive.ubuntu.com precise-updates InRelease [196 kB]
==> base: Get:4 http://security.ubuntu.com precise-security/restricted Sources [4,476 B]
==> base: Get:5 http://security.ubuntu.com precise-security/universe Sources [44.3 kB]
==> base: Get:6 http://security.ubuntu.com precise-security/multiverse Sources [2,214 B]
==> base: Get:7 http://security.ubuntu.com precise-security/main amd64 Packages [578 kB]
==> base: Get:8 http://us.archive.ubuntu.com precise-backports InRelease [54.5 kB]
==> base: Hit http://us.archive.ubuntu.com precise Release.gpg
==> base: Get:9 http://us.archive.ubuntu.com precise-updates/main Sources [495 kB]
==> base: Get:10 http://security.ubuntu.com precise-security/restricted amd64 Packages [11.6 kB]
==> base: Get:11 http://security.ubuntu.com precise-security/universe amd64 Packages [127 kB]
==> base: Get:12 http://us.archive.ubuntu.com precise-updates/restricted Sources [8,708 B]
==> base: Get:13 http://us.archive.ubuntu.com precise-updates/universe Sources [123 kB]
==> base: Get:14 http://us.archive.ubuntu.com precise-updates/multiverse Sources [9,730 B]
==> base: Get:15 http://security.ubuntu.com precise-security/multiverse amd64 Packages [2,687 B]
==> base: Get:16 http://security.ubuntu.com precise-security/main i386 Packages [636 kB]
==> base: Get:17 http://us.archive.ubuntu.com precise-updates/main amd64 Packages [967 kB]
==> base: Get:18 http://us.archive.ubuntu.com precise-updates/restricted amd64 Packages [16.2 kB]
==> base: Get:19 http://us.archive.ubuntu.com precise-updates/universe amd64 Packages [270 kB]
==> base: Get:20 http://us.archive.ubuntu.com precise-updates/multiverse amd64 Packages [16.6 kB]
==> base: Get:21 http://us.archive.ubuntu.com precise-updates/main i386 Packages [1,026 kB]
==> base: Get:22 http://security.ubuntu.com precise-security/restricted i386 Packages [11.6 kB]
==> base: Get:23 http://security.ubuntu.com precise-security/universe i386 Packages [135 kB]
==> base: Get:24 http://security.ubuntu.com precise-security/multiverse i386 Packages [2,871 B]
==> base: Get:25 http://security.ubuntu.com precise-security/main TranslationIndex [208 B]
==> base: Get:26 http://security.ubuntu.com precise-security/multiverse TranslationIndex [199 B]
==> base: Get:27 http://security.ubuntu.com precise-security/restricted TranslationIndex [202 B]
==> base: Get:28 http://security.ubuntu.com precise-security/universe TranslationIndex [205 B]
==> base: Get:29 http://security.ubuntu.com precise-security/main Translation-en [246 kB]
==> base: Get:30 http://us.archive.ubuntu.com precise-updates/restricted i386 Packages [16.1 kB]
==> base: Get:31 http://us.archive.ubuntu.com precise-updates/universe i386 Packages [280 kB]
==> base: Get:32 http://us.archive.ubuntu.com precise-updates/multiverse i386 Packages [16.7 kB]
==> base: Get:33 http://us.archive.ubuntu.com precise-updates/main TranslationIndex [10.6 kB]
==> base: Get:34 http://us.archive.ubuntu.com precise-updates/multiverse TranslationIndex [7,613 B]
==> base: Get:35 http://us.archive.ubuntu.com precise-updates/restricted TranslationIndex [7,297 B]
==> base: Get:36 http://us.archive.ubuntu.com precise-updates/universe TranslationIndex [8,333 B]
==> base: Get:37 http://us.archive.ubuntu.com precise-backports/main Sources [5,922 B]
==> base: Get:38 http://us.archive.ubuntu.com precise-backports/restricted Sources [28 B]
==> base: Get:39 http://security.ubuntu.com precise-security/multiverse Translation-en [1,408 B]
==> base: Get:40 http://security.ubuntu.com precise-security/restricted Translation-en [2,976 B]
==> base: Get:41 http://security.ubuntu.com precise-security/universe Translation-en [81.3 kB]
==> base: Get:42 http://us.archive.ubuntu.com precise-backports/universe Sources [43.1 kB]
==> base: Get:43 http://us.archive.ubuntu.com precise-backports/multiverse Sources [5,750 B]
==> base: Get:44 http://us.archive.ubuntu.com precise-backports/main amd64 Packages [6,477 B]
==> base: Get:45 http://us.archive.ubuntu.com precise-backports/restricted amd64 Packages [28 B]
==> base: Get:46 http://us.archive.ubuntu.com precise-backports/universe amd64 Packages [44.5 kB]
==> base: Get:47 http://us.archive.ubuntu.com precise-backports/multiverse amd64 Packages [5,419 B]
==> base: Get:48 http://us.archive.ubuntu.com precise-backports/main i386 Packages [6,478 B]
==> base: Get:49 http://us.archive.ubuntu.com precise-backports/restricted i386 Packages [28 B]
==> base: Get:50 http://us.archive.ubuntu.com precise-backports/universe i386 Packages [44.3 kB]
==> base: Get:51 http://us.archive.ubuntu.com precise-backports/multiverse i386 Packages [5,413 B]
==> base: Get:52 http://us.archive.ubuntu.com precise-backports/main TranslationIndex [202 B]
==> base: Get:53 http://us.archive.ubuntu.com precise-backports/multiverse TranslationIndex [202 B]
==> base: Get:54 http://us.archive.ubuntu.com precise-backports/restricted TranslationIndex [193 B]
==> base: Get:55 http://us.archive.ubuntu.com precise-backports/universe TranslationIndex [205 B]
==> base: Hit http://us.archive.ubuntu.com precise Release
==> base: Get:56 http://us.archive.ubuntu.com precise-updates/main Translation-en [409 kB]
==> base: Get:57 http://us.archive.ubuntu.com precise-updates/multiverse Translation-en [9,603 B]
==> base: Get:58 http://us.archive.ubuntu.com precise-updates/restricted Translation-en [3,869 B]
==> base: Get:59 http://us.archive.ubuntu.com precise-updates/universe Translation-en [162 kB]
==> base: Get:60 http://us.archive.ubuntu.com precise-backports/main Translation-en [5,737 B]
==> base: Get:61 http://us.archive.ubuntu.com precise-backports/multiverse Translation-en [4,838 B]
==> base: Get:62 http://us.archive.ubuntu.com precise-backports/restricted Translation-en [14 B]
==> base: Get:63 http://us.archive.ubuntu.com precise-backports/universe Translation-en [35.2 kB]
==> base: Hit http://us.archive.ubuntu.com precise/main Sources
==> base: Hit http://us.archive.ubuntu.com precise/restricted Sources
==> base: Hit http://us.archive.ubuntu.com precise/universe Sources
==> base: Hit http://us.archive.ubuntu.com precise/multiverse Sources
==> base: Hit http://us.archive.ubuntu.com precise/main amd64 Packages
==> base: Hit http://us.archive.ubuntu.com precise/restricted amd64 Packages
==> base: Hit http://us.archive.ubuntu.com precise/universe amd64 Packages
==> base: Hit http://us.archive.ubuntu.com precise/multiverse amd64 Packages
==> base: Hit http://us.archive.ubuntu.com precise/main i386 Packages
==> base: Hit http://us.archive.ubuntu.com precise/restricted i386 Packages
==> base: Hit http://us.archive.ubuntu.com precise/universe i386 Packages
==> base: Hit http://us.archive.ubuntu.com precise/multiverse i386 Packages
==> base: Hit http://us.archive.ubuntu.com precise/main TranslationIndex
==> base: Hit http://us.archive.ubuntu.com precise/multiverse TranslationIndex
==> base: Hit http://us.archive.ubuntu.com precise/restricted TranslationIndex
==> base: Hit http://us.archive.ubuntu.com precise/universe TranslationIndex
==> base: Hit http://us.archive.ubuntu.com precise/main Translation-en
==> base: Hit http://us.archive.ubuntu.com precise/multiverse Translation-en
==> base: Hit http://us.archive.ubuntu.com precise/restricted Translation-en
==> base: Hit http://us.archive.ubuntu.com precise/universe Translation-en
==> base: Fetched 6,408 kB in 4s (1,308 kB/s)
==> base: Reading package lists...
==> base: Reading package lists...
==> base: Building dependency tree...
==> base: Reading state information...
==> base: The following extra packages will be installed:
==> base:   libperl5.14 libsensors4 libsnmp-base libsnmp15 perl perl-base perl-modules
==> base: Suggested packages:
==> base:   lm-sensors snmp-mibs-downloader snmpd perl-doc libterm-readline-gnu-perl
==> base:   libterm-readline-perl-perl make libpod-plainer-perl
==> base: The following NEW packages will be installed:
==> base:   libperl5.14 libsensors4 libsnmp-base libsnmp15 lldpd
==> base: The following packages will be upgraded:
==> base:   perl perl-base perl-modules
==> base: 3 upgraded, 5 newly installed, 0 to remove and 181 not upgraded.
==> base: Need to get 11.0 MB of archives.
==> base: After this operation, 4,248 kB of additional disk space will be used.
==> base: Get:1 http://us.archive.ubuntu.com/ubuntu/ precise-updates/main perl amd64 5.14.2-6ubuntu2.4 [4,411 kB]
==> base: Get:2 http://us.archive.ubuntu.com/ubuntu/ precise-updates/main perl-base amd64 5.14.2-6ubuntu2.4 [1,513 kB]
==> base: Get:3 http://us.archive.ubuntu.com/ubuntu/ precise-updates/main perl-modules all 5.14.2-6ubuntu2.4 [3,389 kB]
==> base: Get:4 http://us.archive.ubuntu.com/ubuntu/ precise/main libsensors4 amd64 1:3.3.1-2ubuntu1 [31.9 kB]
==> base: Get:5 http://us.archive.ubuntu.com/ubuntu/ precise-updates/main libperl5.14 amd64 5.14.2-6ubuntu2.4 [1,252 B]
==> base: Get:6 http://us.archive.ubuntu.com/ubuntu/ precise-updates/main libsnmp-base all 5.4.3~dfsg-2.4ubuntu1.3 [216 kB]
==> base: Get:7 http://us.archive.ubuntu.com/ubuntu/ precise-updates/main libsnmp15 amd64 5.4.3~dfsg-2.4ubuntu1.3 [1,334 kB]
==> base: Get:8 http://us.archive.ubuntu.com/ubuntu/ precise/universe lldpd amd64 0.5.5-1 [97.3 kB]
==> base: dpkg-preconfigure: unable to re-open stdin: No such file or directory
==> base: Fetched 11.0 MB in 5s (2,080 kB/s)
==> base: (Reading database ...
==> base: 51095 files and directories currently installed.)
==> base: Preparing to replace perl 5.14.2-6ubuntu2 (using .../perl_5.14.2-6ubuntu2.4_amd64.deb) ...
==> base: Unpacking replacement perl ...
==> base: Preparing to replace perl-base 5.14.2-6ubuntu2 (using .../perl-base_5.14.2-6ubuntu2.4_amd64.deb) ...
==> base: Unpacking replacement perl-base ...
==> base: Processing triggers for man-db ...
==> base: Setting up perl-base (5.14.2-6ubuntu2.4) ...
==> base: (Reading database ...
==> base: 51095 files and directories currently installed.)
==> base: Preparing to replace perl-modules 5.14.2-6ubuntu2 (using .../perl-modules_5.14.2-6ubuntu2.4_all.deb) ...
==> base: Unpacking replacement perl-modules ...
==> base: Selecting previously unselected package libsensors4.
==> base: Unpacking libsensors4 (from .../libsensors4_1%3a3.3.1-2ubuntu1_amd64.deb) ...
==> base: Selecting previously unselected package libperl5.14.
==> base: Unpacking libperl5.14 (from .../libperl5.14_5.14.2-6ubuntu2.4_amd64.deb) ...
==> base: Selecting previously unselected package libsnmp-base.
==> base: Unpacking libsnmp-base (from .../libsnmp-base_5.4.3~dfsg-2.4ubuntu1.3_all.deb) ...
==> base: Selecting previously unselected package libsnmp15.
==> base: Unpacking libsnmp15 (from .../libsnmp15_5.4.3~dfsg-2.4ubuntu1.3_amd64.deb) ...
==> base: Selecting previously unselected package lldpd.
==> base: Unpacking lldpd (from .../lldpd_0.5.5-1_amd64.deb) ...
==> base: Processing triggers for man-db ...
==> base: Processing triggers for ureadahead ...
==> base: Setting up libsensors4 (1:3.3.1-2ubuntu1) ...
==> base: Setting up libperl5.14 (5.14.2-6ubuntu2.4) ...
==> base: Setting up libsnmp-base (5.4.3~dfsg-2.4ubuntu1.3) ...
==> base: Setting up libsnmp15 (5.4.3~dfsg-2.4ubuntu1.3) ...
==> base: Setting up lldpd (0.5.5-1) ...
==> base: Setting up perl-modules (5.14.2-6ubuntu2.4) ...
==> base: Setting up perl (5.14.2-6ubuntu2.4) ...
==> base: Processing triggers for libc-bin ...
==> base: ldconfig deferred processing now taking place
==> eos: Importing base box 'vEOS-4.15.2F'...
==> eos: Matching MAC address for NAT networking...
==> eos: Setting the name of the VM: vagrant_eos_1450958650232_66997
==> eos: Clearing any previously set network interfaces...
==> eos: Preparing network interfaces based on configuration...
    eos: Adapter 1: nat
    eos: Adapter 2: intnet
    eos: Adapter 3: intnet
==> eos: Forwarding ports...
    eos: 443 => 12443 (adapter 1)
    eos: 22 => 2222 (adapter 1)
==> eos: Booting VM...
==> eos: Waiting for machine to boot. This may take a few minutes...
    eos: SSH address: 127.0.0.1:2222
    eos: SSH username: root
    eos: SSH auth method: private key
    eos: Warning: Connection timeout. Retrying...
    eos: Warning: Connection timeout. Retrying...
    eos: Warning: Connection timeout. Retrying...
    eos: Warning: Connection timeout. Retrying...
    eos: Warning: Connection timeout. Retrying...
    eos: Warning: Connection timeout. Retrying...
    eos:
    eos: Vagrant insecure key detected. Vagrant will automatically replace
    eos: this with a newly generated keypair for better security.
    eos:
    eos: Inserting generated public key within guest...
    eos: Removing insecure key from the guest if it's present...
    eos: Key inserted! Disconnecting and reconnecting using new SSH key...
==> eos: Machine booted and ready!
==> eos: Checking for guest additions in VM...
    eos: No guest additions were detected on the base box for this VM! Guest
    eos: additions are required for forwarded ports, shared folders, host only
    eos: networking, and more. If SSH fails on this machine, please install
    eos: the guest additions and repackage the box to continue.
    eos:
    eos: This is not an error message; everything may continue to work properly,
    eos: in which case you may ignore this message.
==> eos: Running provisioner: shell...
    eos: Running: inline script
```

The machines are both up and have been provisioned with some initial configuration. Now let's connect to the vEOS VM and run `show lldp neighbors`:

```
$ vagrant ssh eos
Last login: Thu Dec 24 12:07:04 2015 from 10.0.2.2

Arista Networks EOS shell

-bash-4.1# FastCli
localhost>en
localhost#show lldp neighbors
Last table change time   : 0:01:48 ago
Number of table inserts  : 2
Number of table deletes  : 0
Number of table drops    : 0
Number of table age-outs : 0

Port       Neighbor Device ID               Neighbor Port ID           TTL
Et1        precise64                        0800.271c.bb86             120
Et2        precise64                        0800.27ca.0f72             120
```

As you can see, my vEOS machine can see the Linux machine connected to its Et1 and Et2 interfaces.

When you are done and you want to get rid of your environment you can easily destroy it, liberating resources, with the command `vagrant destroy`:

```
$ vagrant destroy
==> junos: VM not created. Moving on...
==> iosxr: VM not created. Moving on...
    eos: Are you sure you want to destroy the 'eos' VM? [y/N] y
==> eos: Forcing shutdown of VM...
==> eos: Destroying VM and associated drives...
    base: Are you sure you want to destroy the 'base' VM? [y/N] y
==> base: Forcing shutdown of VM...
==> base: Destroying VM and associated drives...
==> base: Running cleanup tasks for 'shell' provisioner...
```

Soon I will blog how to create your own vagrant boxes and how to provision them easily.

[napalm]: https://github.com/napalm-automation/napalm
[vagrant]: https://www.vagrantup.com/
[providers]: https://docs.vagrantup.com/v2/providers/
[virtualbox]: https://www.virtualbox.org
[public_boxes]: https://www.virtualbox.org
[veos]: https://eos.arista.com/using-veos-with-vagrant-and-virtualbox/
[boxes]: https://docs.vagrantup.com/v2/boxes.html
[host_shell]: https://github.com/phinze/vagrant-host-shell
