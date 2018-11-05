{ config, lib, pkgs, ... }:

{
  imports =
    [ <nixpkgs/nixos/modules/installer/scan/not-detected.nix>
    ];

  boot.initrd.availableKernelModules = [
    "xhci_pci" "xhci_hcd" "ehci_pci" "ahci" "uas" "sd_mod" "rtsx_pci_sdmmc"
    "aes_x86_64" "aesni_intel" "cryptd" "usb_storage"
  ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.blacklistedKernelModules = [ "snd_pcsp" "snd_pcm_oss" "pcspkr" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/39333b81-4efb-43fc-b1aa-dc206f4d3b5d";
      fsType = "ext4";
    };

  boot.initrd.luks.devices."cryptroot".device = "/dev/disk/by-uuid/7371081c-d9fb-4228-93ee-b1064531f78b";

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/1f34cca4-70c5-46c2-ae14-5cd394c8b886";
      fsType = "ext3";
    };

  swapDevices = [ { device = "/swapfile"; size = 10000; } ];

  nix.maxJobs = lib.mkDefault 4;
  powerManagement.cpuFreqGovernor = "powersave";
}
