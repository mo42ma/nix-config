{ config, lib, pkgs, ... }:
let
  cfg = config.syslib.nh;
in
{
  # https://github.com/viperML/nh
  options.syslib.nh = {
    enable = lib.mkEnableOption "nh";
    flakePath = lib.mkOption {
      type = lib.types.path;
      description = "Path to flake";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.sessionVariables.NH_FLAKE = "${cfg.flakePath}";
    environment.systemPackages = [ pkgs.nh ];
  };
}
