---
title: Creating your own Vagrant boxes
subtitle: How to create a box with IOS-XR
categories: blog
tags: [ automation, networking ]
---

Creating vagrant boxes is fairly easy. To show you how to do it we will create a vagrant box for IOS-XR. Before we start you will need the following:

 * Vagrant, of course. For more information check the following post: **FIXME**
 * Virtualbox.
 * An OVA for IOS-XR. I am using `iosxrv-k9-demo-5.3.0.ova`.

 <!--more-->

<div class="bs-callout bs-callout-info">
  In order to get it you will need a valid Cisco account. Please, don't ask me how to get it, ask your sales contact or just nag them on twitter for making everything so difficult.
</div>

<div class="bs-callout bs-callout-warning">
  IOS-XR started supporting DHCP client in the management interface in the image 5.3.0 so older images will not work.
</div>

### Creating the base image

Creating a base image is as simple as creating a new VM and configuring it in any way you want. I am not going to explain how to get started with IOS-XR on Virtualbox because there are plenty of posts already doing that. For example [this][example] link.

<div class="bs-callout bs-callout-info">
You just have the follow the steps until you get access to the VM via the serial port.
</div>

Once your VM is ready and you have access to it via the serial port, create the admin user `vagrant` with password `vagrant` and apply the following configuration:

{% highlight text linenos %}
interface MgmtEth0/0/CPU0/0
 ipv4 address dhcp

ssh server v2
ssh server rate-limit 600
xml agent tty
{% endhighlight %}


### Creating the box

Now that we have the VM ready we just have to export it in `.box` format. Go to the CLI and:

{% highlight text linenos %}
interface MgmtEth0/0/CPU0/0
 ipv4 address dhcp

ssh server v2
ssh server rate-limit 600
xml agent tty
lldp
{% endhighlight %}

Now create a file named `Vagrantfile` with the following content:

{% highlight ruby linenos %}
# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.provider 'virtualbox' do |_, override|
    # Disable synced folders
    config.vm.synced_folder ".", "/vagrant", disabled: true
  end

  config.ssh.username = "vagrant"
  config.ssh.passwird = "vagrant"
end
{% endhighlight %}

And finally, execute:

{% highlight text linenos %}
$ vagrant package --base base_vm_for_iosxr --output iosxrv-k9-demo-5.3.0.box --vagrantfile Vagrantfile
==> base_vm_for_iosxr: Attempting graceful shutdown of VM...
    base_vm_for_iosxr: Guest communication could not be established! This is usually because
    base_vm_for_iosxr: SSH is not running, the authentication information was changed,
    base_vm_for_iosxr: or some other networking issue. Vagrant will force halt, if
    base_vm_for_iosxr: capable.
==> base_vm_for_iosxr: Forcing shutdown of VM...
==> base_vm_for_iosxr: Clearing any previously set forwarded ports...
==> base_vm_for_iosxr: Exporting VM...
==> base_vm_for_iosxr: Compressing package to: /Users/dbarroso/Downloads/iosxrv-k9-demo-5.3.0.box
==> base_vm_for_iosxr: Packaging additional file: Vagrantfile

$ ls *.box
iosxrv-k9-demo-5.3.0.box
{% endhighlight %}

<div class="bs-callout bs-callout-info">
In this example, the name of the base VM we created is `base_vm_for_iosxr`. If you have a different name replace the previous command accordingly.
</div>

Now you can stop and delete the base VM you created if you want.

### Importing the box

The last step is to import the box we created before into vagrant:

{% highlight text linenos %}

$ vagrant box add --name IOSXRv-5.3.0 iosxrv-k9-demo-5.3.0.box
==> box: Box file was not detected as metadata. Adding it directly...
==> box: Adding box 'IOSXRv-5.3.0' (v0) for provider:
    box: Unpacking necessary files from: file:///Users/dbarroso/Downloads/iosxrv-k9-demo-5.3.0.box
==> box: Successfully added box 'IOSXRv-5.3.0' (v0) for 'virtualbox'!

$ vagrant box list
CumulusCommunity/cumulus-vx          (virtualbox, 2.5.3)
IOSXRv-5.3.0                         (virtualbox, 0)
hashicorp/precise64                  (virtualbox, 1.1.0)
juniper/ffp-12.1X47-D20.7-packetmode (virtualbox, 0.5.0)
ubuntu/trusty64                      (virtualbox, 20151105.0.0)
vEOS-4.15.2F                         (virtualbox, 0)

{% endhighlight %}

And that's it. You IOS-XR box is ready to use.

### Using your Vagrant box

Now that you have your box ready you can create a Vagrantfile with the configuration you want and get your VM ready in a second. For example, if you create a file name Vagrantfile with the following content:

{% highlight ruby linenos %}
Vagrant.configure(2) do |config|

  config.vm.define "eos" do |eos|
    eos.vm.box = "vEOS-4.15.2F"

    eos.vm.network :forwarded_port, guest: 443, host: 12443, id: 'https'

    eos.vm.network "private_network", virtualbox__intnet: "link_1", ip: "169.254.1.11", auto_config: false
    eos.vm.network "private_network", virtualbox__intnet: "link_2", ip: "169.254.1.11", auto_config: false
  end

  config.vm.define "iosxr" do |iosxr|
    iosxr.vm.box = "IOSXRv-5.3.0"

    iosxr.vm.network :forwarded_port, guest: 22, host: 12202, id: 'ssh'

    iosxr.vm.network "private_network", virtualbox__intnet: "link_1", ip: "169.254.1.11", auto_config: false
    iosxr.vm.network "private_network", virtualbox__intnet: "link_2", ip: "169.254.1.11", auto_config: false
  end

end
{% endhighlight %}

You will get with one command a lab with an EOS switch and an IOS-XR router, each with two interfaces:

{% highlight text linenos %}
$ vagrant up eos iosxr
Bringing machine 'eos' up with 'virtualbox' provider...
Bringing machine 'iosxr' up with 'virtualbox' provider...
==> eos: Importing base box 'vEOS-4.15.2F'...
... Omitting output for brevity...
==> iosxr: Importing base box 'IOSXRv-5.3.0'...
... Omitting output for brevity...

$ vagrant ssh iosxr
vagrant@127.0.0.1's password:
RP/0/0/CPU0:ios#conf
Sat Dec 26 16:51:35.713 UTC
RP/0/0/CPU0:ios(config)#interface GigabitEthernet0/0/0/0
RP/0/0/CPU0:ios(config-if)#no shut
RP/0/0/CPU0:ios(config-if)#interface GigabitEthernet0/0/0/1
RP/0/0/CPU0:ios(config-if)#no shut
RP/0/0/CPU0:ios(config-if)#commit
Sat Dec 26 16:51:47.373 UTC
RP/0/0/CPU0:ios(config-if)#end

RP/0/0/CPU0:ios#show lldp neighbors
Sat Dec 26 16:52:34.939 UTC
Capability codes:
        (R) Router, (B) Bridge, (T) Telephone, (C) DOCSIS Cable Device
        (W) WLAN Access Point, (P) Repeater, (S) Station, (O) Other

Device ID       Local Intf          Hold-time  Capability     Port ID
localhost       Gi0/0/0/0           120        B               Ethernet1
localhost       Gi0/0/0/1           120        B               Ethernet2

Total entries displayed: 2

{% endhighlight %}

Finally, when you are done:

{% highlight text linenos %}
$ vagrant destroy
    iosxr: Are you sure you want to destroy the 'iosxr' VM? [y/N] y
==> iosxr: Forcing shutdown of VM...
==> iosxr: Destroying VM and associated drives...
    eos: Are you sure you want to destroy the 'eos' VM? [y/N] y
==> eos: Forcing shutdown of VM...
==> eos: Destroying VM and associated drives...
{% endhighlight %}

#### Provisioning VMs automatically

VMs can be configured with custom configuration at booting time. How to do it is up to you but given the nature of network operating systems, I suggest using the "host-shell":host-shell plugin. That will allow you to run a script locally that will connect to the device and configure it. Below you can find a very quick and dirty script I often use for this task:

{% highlight python linenos %}

#!/usr/bin/env python

"""
You can use this script in Vagrant like this:

config.vm.define "iosxr" do |iosxr|
  iosxr.vm.box = "IOSXRv-5.3.0"

  iosxr.vm.network :forwarded_port, guest: 22, host: 12202, id: 'ssh'

  iosxr.vm.network "private_network", virtualbox__intnet: "link_1", ip: "169.254.1.11", auto_config: false
  iosxr.vm.network "private_network", virtualbox__intnet: "link_2", ip: "169.254.1.11", auto_config: false

  iosxr.vm.provision "host_shell", inline: <<-SHELL
    ./provision.py iosxr 12202 vagrant vagrant deploy.conf
  SHELL

end
"""

import sys
from pyIOSXR import IOSXR
import pyeapi

from jnpr.junos import Device
from jnpr.junos.utils.config import Config
import jnpr.junos.exception

import pexpect, httplib


def provision_iosxr(port, username, password, config_file):
    device = IOSXR(hostname='127.0.0.1', username=username, password=password, port=port)
    device.open()
    device.load_candidate_config(filename=config_file)

    device.commit_replace_config()


def provision_eos(port, username, password, config_file):
    connection = pyeapi.client.connect(
        transport='https',
        host='localhost',
        username='vagrant',
        password='vagrant',
        port=port
    )
    device = pyeapi.client.Node(connection)

    commands = list()
    commands.append('configure session')
    commands.append('rollback clean-config')

    with open(config_file, 'r') as f:
        lines = f.readlines()

    for line in lines:
        line = line.strip()
        if line == '':
            continue
        if line.startswith('!'):
            continue
        commands.append(line)

    commands[-1] = 'commit'

    device.run_commands(commands)


def provision_junos(port, username, password, config_file):
    device = Device('127.0.0.1', user=username, port=port)
    device.open()
    device.bind(cu=Config)

    with open(config_file, 'r') as f:
        configuration = f.read()

    device.cu.load(configuration, format='text', overwrite=True)

    device.cu.commit()
    device.close()


if __name__ == "__main__":
    os = sys.argv[1]
    port = sys.argv[2]
    username = sys.argv[3]
    password = sys.argv[4]
    config_file = sys.argv[5]
    if os == 'iosxr':
        provision_iosxr(port, username, password, config_file)
    elif os == 'eos':
        provision_eos(port, username, password, config_file)
    elif os == 'junos':
        provision_junos(port, username, password, config_file)

{% endhighlight %}

You can also use

### Conclusion

As you can see it is very easy to create a box. For more information I suggest you to look into the official [documentation][documentation] and if you plan to streamline the creation of boxes I suggest you to look into [packer][packer].

[example]: http://blog.alainmoretti.com/ios-xrv-working-on-virtualbox/
[documentation]: https://docs.vagrantup.com/v2/boxes/base.html
[packer]: https://www.packer.io/intro/getting-started/vagrant.html
[host-shell]: https://github.com/phinze/vagrant-host-shell