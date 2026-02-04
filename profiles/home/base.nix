{ config, lib, pkgs, userConfig, homeConfig, sysConfig, ... }:
let
  cfg = config.profiles.base;

  defaultHomeDirs = {
    x86_64-linux = "/home/${userConfig.userName}";
    aarch64-darwin = "/Users/${userConfig.userName}";
  };

in
{
  options.profiles.base = with lib; {
    enable = mkEnableOption "common settings for homeManager";
    stateVersion = mkOption { type = types.str; };
    sysConfigName = mkOption {
      type = types.nullOr types.str;
      default = sysConfig;
      description = ''
        name of the corresponding nixosConfiguration for the host of this homeConfiguration
      '';
    };
  };

  config = lib.mkIf cfg.enable {

    programs.home-manager.enable = true;

    home = {
      username = lib.mkDefault userConfig.userName;
      homeDirectory = lib.mkDefault defaultHomeDirs.${pkgs.stdenv.hostPlatform.system};
      stateVersion = lib.mkDefault cfg.stateVersion;
      packages = [ pkgs.nh ];
    };

    nix = {
      settings.experimental-features = lib.mkDefault [ "nix-command" "flakes" ];
      package = lib.mkDefault pkgs.nix;
    };

    homelib = {

      fish.enable = lib.mkDefault true;
      helix.enable = lib.mkDefault true;
      atuin.enable = lib.mkDefault true;

      stylix = {
        enable = true;
        theme = "gruvbox-dark-medium";
      };

      just = {
        enable = true;
        homeConfiguration = lib.mkDefault homeConfig;
        hostConfiguration = lib.mkIf (cfg.sysConfigName != null) (lib.mkDefault cfg.sysConfigName);
      };

      git = {
        enable = true;
        commitInfo = {
          name = lib.mkDefault userConfig.git.userName;
          email = lib.mkDefault userConfig.email;
          signKey = lib.mkIf (builtins.hasAttr "signKey" userConfig.git) (lib.mkDefault userConfig.git.signKey);
        };
      };

    };

  };
}
