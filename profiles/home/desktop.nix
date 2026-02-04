{ config, lib, pkgs, userConfig, ... }:
let
  cfg = config.profiles.desktop;
in
{
  options.profiles.desktop = with lib; {
    enable = mkEnableOption "Custom desktop environment based on Hyprland";
    monitors = mkOption {
      type = types.listOf types.str;
      default = [];
      example = ''[
        "eDP-1,1920x1080@60,0x0,1"
        "DP-1,1920x1080@60,1920x0,1"
        "DP-2,1920x1080@60,3840x0,1"
      ]'';
    };
  };

  config = lib.mkIf cfg.enable {

    profiles.base.enable = true;

    homelib = {

      hyprland = {
        enable = true;
        debugMode = lib.mkDefault false;
        keyMap = lib.mkDefault userConfig.localization.keymap;
        inherit (cfg) monitors;
      };

      kitty.enable = lib.mkDefault true;
      firefox.enable = lib.mkDefault true;
      helix.clipboardPkg = lib.mkDefault pkgs.wl-clipboard;
      satty.enable = true;

      waybar.enable = lib.mkDefault true;
      dunst.enable = lib.mkDefault true;

      gammastep = {
        enable = lib.mkDefault true;
        location = {
          latPath = lib.mkDefault config.sops.secrets."location/latitude".path;
          lonPath = lib.mkDefault config.sops.secrets."location/longitude".path;
        };
        systemdBindTarget = "hyprland-session.target";
      };

      bitwarden.enableGui = lib.mkDefault true;
    };

    home.packages = with pkgs; [
      trilium-next-desktop
      signal-desktop
      lazygit
    ];

    # there is also services.poweralertd which seems more maintained
    # but it requires upower which I'd need to include in nixosConfiguration
    services.batsignal = {
      enable = true;
      extraArgs = [
        "-w 20" # warn
        "-c 10" # critical
        "-d 5" # danger
        "-p" # show message when battery begins charging/discharging
        "-e" # cause notifications to expire
      ];
    };

    # volume/brightness notification
    # alternative: https://github.com/heyjuvi/avizo
    services.swayosd = {
      enable = true;
      topMargin = 0.9;
    };

  };

}
