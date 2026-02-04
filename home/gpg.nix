{ config, lib, pkgs, ...}:

{

  options.homelib.gpg.enable = lib.mkOption {
    type = lib.types.bool;
    default = false;
    description = "Enable gpg and gpg-agent";
  };

  config = lib.mkIf config.homelib.gpg.enable {

    programs.gpg = {
      enable = true;
      mutableKeys = true;
    };

    services.gpg-agent = {
      enable = true;
      enableFishIntegration = true;
      enableScDaemon = false;
      pinentry.package = pkgs.pinentry-tty;
    };

  };

}
