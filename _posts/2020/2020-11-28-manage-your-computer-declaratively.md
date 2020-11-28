---
title: Managing your computer declaratively
subtitle: nix rules
categories: blog
tags: [ tools , automation ]
---

Recently I have been nagging people about [nix](https://nixos.org) and [home-manager](https://github.com/nix-community/home-manager) and I always get the same comment back "looks cool, how do I get started?". Truth be told, the setup has a bit of a steep learning curve so figured I'd write a short blog post to point people in the right direction.

Before we begin, let me explain what the point of these tools are; to declaratively manage your environment/laptop/server. With this you should be able to declare your environment (required software, configurations, etc) and simply execute a command to let `nix` do its magic and keep your environment ready to use. In my personal case I use `nixos` (a linux distro with `nix` at its core) to manage my raspberry pi (which is out of the scope of this post) and `nix-darwin` and `home-manager` to manage both my personal and corporate laptops. Thanks to `nix` I can maintain both computers effortlessly, and, in case of having to reinstall any, have them up to speed in less than an hour after the OS is done installing.

If you are still interested, you need three pieces to manage macos:

1. `nix` itself, which you can install following the instructions [here](https://nixos.org/manual/nix/stable/#sect-macos-installation)
2. `nix-darwin`, which you can install following these other [instructions](https://github.com/LnL7/nix-darwin#install)
3. add `home-manager` as a "nix channel" as instructed [here](https://nix-community.github.io/home-manager/index.html#sec-install-nix-darwin-module)

Ok, now that you are ready, let's try it out. We are going to do the following:

1. Configure `zsh` as our shell and to make use of tools like `ohmyzsh`, `thefuck`, `fzf` and `jump`
2. Configure `git` declaratively
3. Configure the macos dock to hide automatically
4. Configure a schedule job to clean docker (I personally manage docker outside of `nix` using docker desktop for mac)
5. Install some python tools like `virtualenvwrapper` and `poetry`
6. Install and configure `golang`

Start by editing the file `.nixpkgs/darwin-configuration.nix` and adding (don't forget to change the user accordingly):

``` nix
{ config, pkgs, ... }:

{
  imports = [
    <home-manager/nix-darwin>
    ./git.nix
    ./zsh.nix
  ];

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = [
  ];

  # Auto upgrade nix package and the daemon service.
  # services.nix-daemon.enable = true;
  nix.package = pkgs.nix;

  programs.zsh.enable = true;

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;

  # hide the dock automatically
  system.defaults = {
    dock = {
      autohide = true;
      orientation = "bottom";
    };
  };

  # keeping docker clean
  launchd.user.agents.dockerclean = {
    script ="/usr/local/bin/docker system prune --volumes -f";

    serviceConfig.StartCalendarInterval = [
      { Minute = 20; Hour = 11;}
    ];

  };

  home-manager.useUserPackages = true;

  home-manager.users.dbarroso = { pkgs, ... }: {
    home.packages = with pkgs; [
      jump
      poetry
      python38Packages.virtualenv
      python38Packages.virtualenvwrapper
      thefuck
      silver-searcher
    ];

    programs.fzf = {
      enable = true;
    };

    programs.go = {
      enable = true;
    };

  };

}
```

In addition, you should edit `~/.nixpkgs/git.nix` and enter something similar to:

``` nix
{ config, pkgs, ... }:

{
  # my global gitignore
  home-manager.users.dbarroso.home.file."gitignore" = {
    text = ''
    tags
    .DS_Store
    '';
    target = ".gitignore";
  };

  home-manager.users.dbarroso.programs.git = {
    enable = true;
    userName = "David Barroso";
    userEmail = "fake@email.com";

    extraConfig = {
      core = {
        excludesFile = "~/.gitignore";
      };
      pull = {
        rebase = false;
      };
      url = {
        "ssh://git@github.com" = {
          insteadOf = "https://github.com";
        };
      };

    };
  };

}
```

And finally, edit `~/.nixpkgs/zsh.nix` and add:

``` nix
{ config, pkgs, ... }:

{
  home-manager.users.dbarroso.programs.zsh = {
    enable = true;

    enableAutosuggestions = true;
    enableCompletion = true;

    oh-my-zsh = {
      enable = true;
      theme = "robbyrussell";

      plugins = [
        "dash"
        "docker"
        "docker-compose"
        "git"
        "golang"
      ];
    };

    initExtra = ''
      . virtualenvwrapper.sh

      eval "$(jump shell)"

      eval $(thefuck --alias)

      if [ -e /Users/dbarroso/.nix-profile/etc/profile.d/nix.sh ]; then . /Users/dbarroso/.nix-profile/etc/profile.d/nix.sh; fi # added by Nix installer
    '';
  };

}
```

Once you have your config ready you just have to execute:

```
darwin-rebuild switch
```

And your system should be ready :)

For reference, other stuff I manage with this includes things like:

1. alacritty
2. gpg + yubikey
3. tmux
4. nvim
5. weechat
6. ssh configuration
7. many other tools like the rust toolchain, google cloud sdk, etc...

I know this was sparse on details but hopefully this was enough to get you interested and point you in the right direction.
