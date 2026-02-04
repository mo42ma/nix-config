{ config, pkgs, lib, ... }:
let
  cfg = config.homelib.git;
  gitConfig = import ./gitconfig.nix {};
  gitAliases = import ./aliases.nix { inherit pkgs lib; };
  gitIgnore = import ./gitignore.nix {};
in
{
  options.homelib.git = {

    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable git";
    };

    aliases.enable = lib.mkOption {
      type = lib.types.bool;
      default = cfg.enable;
      description = "Manage git aliases";
    };

    ignore.enable = lib.mkOption {
      type = lib.types.bool;
      default = cfg.enable;
      description = "Manage git ignores";
    };

    configOverwritePaths = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      example = ''[ "git/.gitconfig" ]'';
      description = ''
        Defines paths (relative to ~) to additional config snippets. Can be used
        to overwrite values for all repos below these paths recursively.
        -> Dont need to put user/email in the code
      '';
    };

    commitInfo = {
      name = lib.mkOption {
        type = lib.types.str;
        description = "User name for commits";
      };
      email = lib.mkOption {
        type = lib.types.str;
        description = "User email for commits";
      };
      signKey = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Enable commit signing with given gpg key";
      };
    };

  };

  config = lib.mkIf cfg.enable {

    home.packages = [ pkgs.git ];

    programs.git = {
      enable = true;

      settings = {
        user = {
          inherit (cfg.commitInfo) name email;
        };
        alias = lib.mkIf cfg.aliases.enable gitAliases;
      } // gitConfig;

      ignores = lib.mkIf cfg.ignore.enable gitIgnore;

      includes =
        builtins.map (item: { path = item; }) cfg.configOverwritePaths;

      signing = lib.mkIf (cfg.commitInfo.signKey != null) {
        key = cfg.commitInfo.signKey;
        signByDefault = true;
      };
    };
  };
}
