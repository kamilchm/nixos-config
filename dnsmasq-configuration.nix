{ config, lib, pkgs, ... }:

{
  services.dnsmasq = {
    enable = true;
    resolveLocalQueries = true;
    servers = [ # https://github.com/NixOS/nixpkgs/pull/15560 ?
      ''/./127.0.0.1#5300''
      ''8.8.8.8''
      ''8.8.4.4''
    ];
  };
}
