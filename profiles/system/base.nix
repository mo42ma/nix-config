{ config, lib, pkgs, hostConfig, userConfig, ... }:
let
  cfg = config.profiles.base;
in
{
  options.profiles.base = with lib; {
    enable = mkEnableOption "server base profile";
    stateVersion = mkOption { type = types.str; };
    hostName = mkOption { type = types.str; default = hostConfig; };
  };

  config = lib.mkIf cfg.enable {

    system.stateVersion = cfg.stateVersion;

    boot.loader = {
      systemd-boot.enable = lib.mkDefault true;
      efi.canTouchEfiVariables = lib.mkDefault true;
    };

    networking = {
      hostName = lib.mkDefault hostConfig;
      firewall.enable = lib.mkDefault true;
    };

    programs.fish.enable = lib.mkDefault true;
    environment.enableAllTerminfo = lib.mkDefault true; # i.e. for kitty

    syslib = {

      nix.enable = lib.mkDefault true;

      users = {
        mutable = lib.mkDefault true;
        mainUser = {
          name = userConfig.userName;
          shell = lib.mkDefault pkgs.fish;
        };
      };

      localization = {
        enable = true;
        timezone = lib.mkDefault userConfig.localization.timezone;
        locale = lib.mkDefault userConfig.localization.locale;
        keymap = lib.mkDefault userConfig.localization.keymap;
      };

    };

    environment = {
      shellAliases = {
        la = "ls -lah";
        lh = "ls -lh";
        sctl = "systemctl";
        sctls = "systemctl status";
        jctl = "journalctl";
        jctlu = "journalctl -eu";
        jctlf = "journalctl -fu";
      };
      systemPackages = with pkgs; [
        vim
        git
        dig
        lsof
        killall
        ripgrep
        fd
        jq
        gdu
        dysk
        rsync
        helix
        btop
        tealdeer
        pciutils
        nettools
      ];
    };

  };
}
