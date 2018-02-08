{ config, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
      
      <nixpkgs/nixos/modules/programs/command-not-found/command-not-found.nix>
    ];

  hardware = {
    bluetooth.enable = true;
    pulseaudio.enable = true;
    cpu.intel.updateMicrocode = true;
    opengl.extraPackages = [ pkgs.vaapiIntel ];

    trackpoint = {
      enable = true;
      sensitivity = 200;
      emulateWheel = true;
    };
  };  

  boot = {
    vesa = false;

    kernelPackages = pkgs.linuxPackages_4_14;

    initrd = {
      kernelModules = [ "xhci_hcd" "ehci_pci" "ahci" "usb_storage" "aesni-intel" "i915" ];
      availableKernelModules = [ "scsi_wait_scan" ];
      
      luks.devices = [
        { name = "luksroot"; device = "/dev/sda2"; preLVM = true; }
      ];
    };
    kernelModules = [ "kvm-intel" "msr" "bbswitch" ];
    blacklistedKernelModules = [ "snd_pcsp" "pcspkr" ];

    kernelParams = [
      "i915.enable_ips=0"
    ];
    extraModprobeConfig = ''
      options snd_hda_intel mode=auto power_save=1 index=1
    '';

    loader.grub = {
      enable = true;
      version = 2;
      device = "/dev/sda";
      memtest86.enable = false;
      configurationLimit = 50;
    };

    plymouth.enable = true;

    cleanTmpDir = true;
  };

  time.timeZone = "Europe/Warsaw";

  networking = {
    hostName = "black";
    extraHosts = ''
      127.0.0.1   black
    '';
    networkmanager = {
      enable = true;
      unmanaged = [ "interface-name:ve*" "interface-name:vboxnet*" ]; 
    };
    firewall = {
      allowedTCPPorts = [ 8080 ];
      trustedInterfaces = [ "docker0" ];
      checkReversePath = false;
    };
  };

  # Select internationalisation properties.
  i18n = {
    consoleFont = "lat9w-16";
    consoleKeyMap = "pl";
    defaultLocale = "pl_PL.UTF-8";
  };

  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
      xlibs.xf86videointel
      vaapiIntel
      libdrm
      xscreensaver
      pmutils
      networkmanagerapplet
      openconnect
      networkmanager_openconnect
      ntfs3g
      gtk-engine-murrine
      git
      tig
      wget
  ];

  programs = {
    ssh.startAgent = true;

    vim.defaultEditor = true;
  };

  services = {
    acpid.enable = true;

    dbus.enable = true;
    devmon.enable = true;
    printing.enable = true;
    udev.packages = [ pkgs.libmtp ];

    dnsmasq = {
      enable = true;
      resolveLocalQueries = true;
      servers = [ # https://github.com/NixOS/nixpkgs/pull/15560 ?
        ''/./127.0.0.1#5300''
        ''8.8.8.8''
        ''8.8.4.4''
      ];
    };

    xserver = {
      enable = true;

      videoDrivers = [ ];
      
      layout = "pl";
      
      inputClassSections = [
      ''
        Identifier "evdev touchpad off"
        MatchIsTouchpad "on"
        MatchDevicePath "/dev/input/event*"
        Driver "evdev"
        Option "Ignore" "true"
      ''
      ];

      desktopManager.xfce.enable = true;
      windowManager.qtile.enable = true;

      displayManager.sessionCommands = ''
        xscreensaver -no-splash &
      '';

      displayManager.slim.enable = true;
      displayManager.slim.extraConfig = ''
        sessionstart_cmd    ${pkgs.xorg.sessreg}/bin/sessreg -a -l tty7 %user
        sessionstop_cmd     ${pkgs.xorg.sessreg}/bin/sessreg -d -l tty7 %user
      '';

      xautolock = {
        enable = true;
        locker = "xscreensaver-command -l";
      };
    };

    physlock.enable = true;

    gnome3.at-spi2-core.enable = true;
  };


  powerManagement = {
    enable = true;
    cpuFreqGovernor = "ondemand";
    scsiLinkPolicy = "max_performance";
  };

  fonts = {
    enableFontDir = true;
    enableGhostscriptFonts = true;
    fonts = with pkgs; [
       corefonts
       dejavu_fonts
       inconsolata
       liberation_ttf
       terminus_font
       ttf_bitstream_vera
       vistafonts
    ];
  };

  virtualisation.docker = {
    enable = true;
    storageDriver = "overlay";
    extraOptions = "--dns 172.17.0.1";
  };
  virtualisation.virtualbox.host.enable = true;
  virtualisation.libvirtd = {
    enable = true;
    enableKVM = true;
  };

  users.extraUsers.kamil = {
    isNormalUser = true;
    uid = 1000;
    extraGroups = [ "wheel" "networkmanager" "audio" "video" "lp" "power" "disk" "storage" "plugdev" "docker" "libvirtd" ];
  };

}
