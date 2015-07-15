{ config, lib, pkgs, ... }:

{
  imports =
    [ <nixpkgs/nixos/modules/installer/scan/not-detected.nix>
    ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/9406e328-fa40-4d80-8a8c-0dca6d8ce22d";
      fsType = "ext4";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/f898913a-5e65-45d3-9a90-9e4f6334ea9f";
      fsType = "ext4";
    };

  swapDevices = [ ];

  nix.maxJobs = 4;
}
