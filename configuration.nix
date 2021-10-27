{ config, pkgs, ... }:

{
  nix.nixPath =  [ "/home/kamil" "nixos-config=/etc/nixos/configuration.nix" ];
  nix.useSandbox = true;
  # nix.systemFeatures = [ "gccarch-broadwell" ];
  # pkgs.hostPlatform.platform = "broadwell"; 

  imports =
    [
      ./hardware-configuration.nix
      ./dnsmasq-configuration.nix

      ./cachix.nix
      
      <nixpkgs/nixos/modules/programs/command-not-found/command-not-found.nix>
    ];

  hardware = {
    bluetooth = {
      enable = true;
      settings = {
        General = { Enable = "Source,Sink,Media,Socket"; };
      };
    };
    pulseaudio.enable = true;
    pulseaudio.package = pkgs.pulseaudioFull;
    cpu.intel.updateMicrocode = true;
    opengl = {
      enable = true;
      extraPackages = with pkgs; [ vaapiIntel vaapiVdpau libvdpau-va-gl intel-ocl ];
    };
  };  

  boot = {
    vesa = false;

    kernelPackages = pkgs.linuxPackages_5_14;

    kernelParams = [
      "i915.enable_ips=0"
      "i915.enable_psr=0" # https://bugs.freedesktop.org/show_bug.cgi?id=111088
    ];
    extraModprobeConfig = ''
      options snd_hda_intel power_save=1
    '';

    kernel.sysctl = {
      "vm.dirty_bytes" = 15000000;
      
      # https://www.kernel.org/doc/html/latest/admin-guide/sysrq.html
      # 2+4+8+16+32+64+256
      "kernel.sysrq" = 382; 
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

  system.stateVersion = "19.03";

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
    #defaultLocale = "pl_PL.UTF-8";
    defaultLocale = "en_US.UTF-8";
  };
  console = {
    font = "lat9w-16";
    keyMap = "pl";
  };

  nixpkgs.config = { 
    allowUnfree = true;
    packageOverrides = pkgs: {
      bluez = pkgs.bluez5;
    };
  };

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
      brlaser
  ];

  programs = {
    ssh.startAgent = true;

    gnupg.agent.enable = true;

    vim.defaultEditor = true;

    adb.enable = true;
  };

  services = {
    acpid.enable = true;

    dbus.enable = true;
    devmon.enable = true;
    printing.enable = true;
    udev = {
      packages = [ pkgs.libmtp ];
    };
    udisks2.enable = true;

    xserver = {
      enable = true;

      videoDrivers = [ "intel" "mesa" ];
      resolutions = [ { x = 1920; y = 1080; } ];
      
      layout = "pl";
      
      libinput = {
        enable = true;
      };
      synaptics.enable = false;
      inputClassSections = [
        ''
          Identifier "Slow down dell Trackpoint"
          MatchProduct "DualPoint Stick"
          Driver "libinput"
          Option "Accel Speed" "-0.5"
        ''
        ''
          Identifier "Slow down Thinkpad Keyboard Trackpoint"
          MatchProduct "ThinkPad Compact Bluetooth Keyboard with TrackPoint"
          Driver "libinput"
          Option "Accel Speed" "-0.4"
        ''
      ];

      desktopManager.xfce.enable = true;
      windowManager.qtile.enable = true;

      displayManager.sessionCommands = ''
        xscreensaver -no-splash &
      '';

      displayManager.lightdm.enable = true;
    };

    physlock.enable = true;

    gnome.at-spi2-core.enable = true;

    ipfs = {
      enable = false;
      gatewayAddress = "/ip4/127.0.0.1/tcp/23456";
    };

  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  
  powerManagement = {
    enable = true;
    scsiLinkPolicy = "max_performance";
  };

  fonts = {
    fontDir = { enable = true; };
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
  # virtualisation.virtualbox.host.enable = true;
  virtualisation.libvirtd = {
    enable = true;
    qemuPackage = pkgs.qemu_kvm;
  };

  users.extraUsers.kamil = {
    isNormalUser = true;
    uid = 1000;
    extraGroups = [ "wheel" "networkmanager" "audio" "video" "lp" "power" "disk" "storage" "plugdev" "docker" "libvirtd" "kvm" "adbusers" ];
  };

}
