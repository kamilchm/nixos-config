{ config, pkgs, ... }:

{
  nix.useSandbox = true;

  imports =
    [
      ./hardware-configuration.nix
      ./dnsmasq-configuration.nix
      
      <nixpkgs/nixos/modules/programs/command-not-found/command-not-found.nix>
    ];

  hardware = {
    bluetooth = {
      enable = true;
      extraConfig = ''
        [general]
        Enable=Source,Sink,Media,Socket
      '';
    };
    pulseaudio.enable = true;
    pulseaudio.package = pkgs.pulseaudioFull;
    cpu.intel.updateMicrocode = true;
    opengl.extraPackages = with pkgs; [ vaapiIntel vaapiVdpau libvdpau-va-gl ];
  };  

  boot = {
    vesa = false;

    kernelPackages = pkgs.linuxPackages_4_19;

    kernelParams = [
      "i915.enable_ips=0"
    ];
    extraModprobeConfig = ''
      options snd_hda_intel mode=auto power_save=1 index=1
    '';

    kernel.sysctl = {
        "vm.dirty_bytes" = 15000000;
    };

    loader.grub = {
      enable = true;
      version = 2;
      device = "/dev/sda";
      memtest86.enable = false;
      configurationLimit = 50;
    };

    plymouth.enable = true;

    supportedFilesystems = [ "exfat" ];

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

    xserver = {
      enable = true;

      videoDrivers = [ "intel" ];
      
      layout = "pl";
      
      libinput.enable = true;
      synaptics.enable = false;
      inputClassSections = [
        ''
          Identifier "Enable libinput for TrackPoint"
          MatchIsPointer "on"
          Driver "libinput"
          Option "Accel Speed" "-0.4"
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
  };

  users.extraUsers.kamil = {
    isNormalUser = true;
    uid = 1000;
    extraGroups = [ "wheel" "networkmanager" "audio" "video" "lp" "power" "disk" "storage" "plugdev" "docker" "libvirtd" ];
  };

}
