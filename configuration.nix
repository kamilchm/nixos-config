{ config, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
    ];

  hardware = {
    bluetooth.enable = true;
    pulseaudio.enable = true;
    cpu.intel.updateMicrocode = true;
    bumblebee = {
      enable = true;
      group = "video";
    };

    trackpoint = {
      enable = true;
      sensitivity = 200;
      emulateWheel = true;
    };
  };  

  boot = {
    vesa = false;

    kernelPackages = pkgs.linuxPackages_4_1;

    initrd = {
      kernelModules = [ "xhci_hcd" "ehci_pci" "ahci" "usb_storage" "aesni-intel" "fbcon" "i915" ];
      availableKernelModules = [ "scsi_wait_scan" ];
      
      luks.devices = [
        { name = "luksroot"; device = "/dev/sda2"; preLVM = true; }
      ];
    };
    kernelModules = [ "kvm-intel" "msr" ];
    extraModprobeConfig = ''
      options snd_hda_intel mode=auto power_save=1 index=1
    '';
    blacklistedKernelModules = [ "snd_pcsp" "pcspkr" ];
    
    loader.grub = {
      enable = true;
      version = 2;
      device = "/dev/sda";
      memtest86.enable = false;
      configurationLimit = 50;
    };
  };

  time.timeZone = "Europe/Warsaw";

  networking.hostName = "black";
  networking.extraHosts = "127.0.0.1 black";
  networking.networkmanager.enable = true;

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
      oxygen-gtk2
      oxygen-gtk3
      gtk-engine-murrine
      git
      wget
      vim
  ];

  services = {
    acpid.enable = true;
    acpid.lidEventCommands = ''
      grep -q closed /proc/acpi/button/lid/LID0/state && \
      /run/current-system/sw/bin/systemctl suspend
    '';

    dbus.enable = true;
    devmon.enable = true;

    xserver = {
      enable = true;

      videoDrivers = [ "intel" ]; #"nvidiaLegacy340" ];
      vaapiDrivers = [ pkgs.vaapiIntel ];
      
      deviceSection = ''
	#Identifier "Intel Graphics"
	#Option "AccelMethod" "uxa"
	Option "AccelMethod" "sna"
	Option "Backlight" "intel_backlight"
	BusID "PCI:0:2:0"
      '';

      layout = "pl";
      
      synaptics.enable = false;

      desktopManager.xfce.enable = true;
      windowManager.qtile.enable = true;

      displayManager.sessionCommands = ''
        xscreensaver -no-splash &
      '';

      displayManager.slim.enable = true;
    };
  };

  services.printing.enable = true;

  powerManagement = {
    enable = true;
    cpuFreqGovernor = "ondemand";
    resumeCommands = "/run/current-system/sw/bin/xscreensaver-command -lock";
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

  virtualisation.docker.enable = true;

  users.extraUsers.kamil = {
    isNormalUser = true;
    uid = 1000;
    extraGroups = [ "wheel" "networkmanager" "auio" "video" "power" "docker" ];
  };

}
