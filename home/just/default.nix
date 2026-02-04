{ pkgs, config, lib, ... }:
let
  cfg = config.homelib.just;
in
{
  options.homelib.just = {
    enable = lib.mkEnableOption "just";
    path = lib.mkOption {
      type = lib.types.str;
      description = "Path of the nix just build file (relative to ~)";
      default = "justfile";
    };
    flakePath = lib.mkOption {
      type = lib.types.str;
      description = "Path of nix flake to work on";
      default = "${config.home.homeDirectory}/nix-config";
    };
    hostConfiguration = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      description = "Name of the host configuration to build";
      default = null;
    };
    homeConfiguration = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      description = "Name of the home-manager configuration to build";
      default = null;
    };
  };

  config = lib.mkIf cfg.enable {

    home.packages = [ pkgs.just ];

    home.file.${cfg.path} = {
      text = lib.concatStringsSep "\n" [
        "set working-directory := '${cfg.flakePath}'\n"
        (import ./nixBuild.nix { inherit cfg lib pkgs; })
        (import ./nixDiff.nix { inherit cfg lib pkgs; })
      ];
    };

  };
}
