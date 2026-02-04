{ config, lib, ... }:
let
  cfg = config.syslib.nix;
in
{

  options.syslib.nix = with lib; {
    enable = mkEnableOption "nixConfig";
    remoteManaged = mkOption {
      type = types.bool;
      description = "If it shall be possible to manage the system remotely with nixos-rebuild switch --target-host X";
      default = false;
    };
  };

  config.nix = lib.mkIf cfg.enable {

    settings = {
      experimental-features = [ "nix-command" "flakes" ];

      # trusted-users effectively have root rights because they can modify nix store however they want
      # doesnt really matter for @wheel users as they also have unlimited sudo rights
      trusted-users = lib.mkIf cfg.remoteManaged [ "@wheel" ];
    };

    gc = {
      automatic = true;
      dates = "daily";
      options = "--delete-older-than 30d";
    };

  };
}
