{ config, lib, ... }:
let
  cfg = config.syslib.displaylink;
in
{

  options.syslib.displaylink.enable = lib.mkEnableOption "displaylink docking station driver";

  config = lib.mkIf cfg.enable {

    nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
     "displaylink"
    ];

    # also required for wayland
    services.xserver.videoDrivers = [ "displaylink" ];

  };

}
