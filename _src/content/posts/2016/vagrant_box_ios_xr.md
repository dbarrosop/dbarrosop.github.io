---
title: How to create a vagrant for IOS-XR
date: "2016-01-14T18:00:00+02:00"
tags: [ automation, networking ]
---

Creating vagrant boxes is fairly easy and very useful. Using vagrant boxes that are publicly available is preferred as it makes easier to share your environment but in some cases you might want to tweak a bit an existing box or you might want to create your own because there is no box available for a particular virtual appliance.

As mentioned previously, creating a vagrant box is very simple, you only have to create a VM on your provisioner and export it as it is. To show you how to do it we will create a vagrant box for IOS-XR. Before we start you will need the following:

 * Vagrant, of course. For more information check this [post]({% post_url 2016-01-08-vagrant-for-network-engineers %}).
 * Virtualbox.
 * An OVA or a VMDK for IOS-XR. I am using `iosxrv-k9-demo-5.3.0.ova`.

{{<box class="bs-callout bs-callout-info">}}
  In order to get it you will need a valid Cisco account. Ask your sales representative or just nag them on twitter for making everything so difficult. The latter will not work but at least you will vent ;)
{{</box>}}

{{<box class="bs-callout bs-callout-warning">}}
  IOS-XR started supporting DHCP client in the management interface in the image 5.3.0 so older images will not work.
{{</box>}}

### Creating the base image

Creating a base image is as simple as creating a new VM and configuring it in any way you want. I am not going to explain how to get started with IOS-XR on Virtualbox because there are plenty of posts already doing that. For example, [this post][example].

<div class="bs-callout bs-callout-info">
You just have the follow the steps until you get access to the VM via the serial port. I suggest to do two things differently from that post; don't clone the VM you are creating and assign only one single network interface so you can manage the network interfaces with vagrant.
</div>

Once your VM is ready and can access it using the serial port use the initial configuration wizard to create the admin user `vagrant` with password `vagrant` and apply the following configuration:

```shell
interface MgmtEth0/0/CPU0/0
 ipv4 address dhcp

ssh server v2
ssh server rate-limit 600
xml agent tty
```


### Creating the box

Now that we have the VM ready we just have to export it in `.box` format. First, go to a temporal folder and create a file named `Vagrantfile` with the following content:

```ruby
# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
  config.vm.provider 'virtualbox' do |_, override|
    # Disable synced folders
    config.vm.synced_folder ".", "/vagrant", disabled: true
  end

  config.ssh.username = "vagrant"
  config.ssh.password = "vagrant"
end
```

Go to your terminal and execute the following command in the same temporal folder you created the `Vagrantfile`:

```shell
/tmp/vagrant_tmp$ vagrant package --base base_vm_for_iosxr --output iosxrv-k9-demo-5.3.0.box --vagrantfile Vagrantfile
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

/tmp/vagrant_tmp$ ls *.box
iosxrv-k9-demo-5.3.0.box
```

<div class="bs-callout bs-callout-info">
In this example, the name of the base VM we created is <code>base_vm_for_iosxr</code>. If you named your VM differently replace the previous command accordingly.
</div>

Now you can stop and delete the base VM you created if you want.

### Importing the box

The last step is to import the box we created before into vagrant:

```shell
/tmp/vagrant_tmp$ vagrant box add --name IOSXRv-5.3.0 iosxrv-k9-demo-5.3.0.box
==> box: Box file was not detected as metadata. Adding it directly...
==> box: Adding box 'IOSXRv-5.3.0' (v0) for provider:
    box: Unpacking necessary files from: file:///Users/dbarroso/Downloads/iosxrv-k9-demo-5.3.0.box
==> box: Successfully added box 'IOSXRv-5.3.0' (v0) for 'virtualbox'!

/tmp/vagrant_tmp$ vagrant box list
CumulusCommunity/cumulus-vx          (virtualbox, 2.5.5)
IOSXRv-5.3.0                         (virtualbox, 0)
csr1000v                             (virtualbox, 0)
hashicorp/precise64                  (virtualbox, 1.1.0)
juniper/ffp-12.1X47-D20.7-packetmode (virtualbox, 0.5.0)
ubuntu/trusty64                      (virtualbox, 20151105.0.0)
vEOS-4.15.2F                         (virtualbox, 0)
```

And that's it. You IOS-XR box is ready to use.

### Using your Vagrant box

Now that you have your box ready you can create a `Vagrantfile` with your lab configuration and have it ready in a matter of seconds. For example, if you create a `Vagrantfile` with the following content:

```ruby
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
```

You will get with one command a lab with an EOS switch and an IOS-XR router, each with two interfaces:

```shell
/tmp/vagrant_tmp$ vagrant up eos iosxr
Bringing machine 'eos' up with 'virtualbox' provider...
Bringing machine 'iosxr' up with 'virtualbox' provider...
==> eos: Importing base box 'vEOS-4.15.2F'...
... Omitting output for brevity...
==> iosxr: Importing base box 'IOSXRv-5.3.0'...
... Omitting output for brevity...
```

Now you can connect to your IOS-XR machine, enable the interfaces and check with LLDP that the lab is connected as you wanted:

```shell
/tmp/vagrant_tmp$ vagrant ssh iosxr
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
```

Finally, when you are done you can liberate resources by stopping the VMs or just destroying the lab:

```shell
/tmp/vagrant_tmp$ vagrant destroy
    iosxr: Are you sure you want to destroy the 'iosxr' VM? [y/N] y
==> iosxr: Forcing shutdown of VM...
==> iosxr: Destroying VM and associated drives...
    eos: Are you sure you want to destroy the 'eos' VM? [y/N] y
==> eos: Forcing shutdown of VM...
==> eos: Destroying VM and associated drives...
```

#### Provisioning VMs automatically

Soon I will blog on how to auto provision the VMs automatically in a very simple way.

### Conclusion

As you can see it is very easy to create a box. For more information I suggest you to look into the official [documentation][documentation] and if you plan to create a lot of boxes and you want to automate the process I suggest you to look into [packer][packer].

[example]: http://blog.alainmoretti.com/ios-xrv-working-on-virtualbox/
[documentation]: https://docs.vagrantup.com/v2/boxes/base.html
[packer]: https://www.packer.io/intro/getting-started/vagrant.html
[host-shell]: https://github.com/phinze/vagrant-host-shell
