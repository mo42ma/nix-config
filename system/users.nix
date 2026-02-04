{ config, lib, pkgs, ... }:
let
  cfg = config.syslib.users;
in
{
  options.syslib.users = {

    mainUser = {
      name = lib.mkOption { type = lib.types.str; };
      shell = lib.mkOption {
        type = lib.types.package;
        description = "The default shell";
        default = pkgs.bash;
      };
      extraGroups = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ "wheel" "networkmanager" ];
      };
      passwordHashPath = lib.mkOption {
        type = lib.types.nullOr lib.types.path;
        description = ''
          Path to file containing "username:hashedpw" hashed pw (created with mkpasswd -s).
        '';
        default = null;
      };
    };

    mutable = lib.mkOption {
      type = lib.types.bool;
      description = ''
        Whether users can be modified with f.e. passwd
        If this is set to false, passwordHashPath has to be defined per user
      '';
      default = true;
    };

  };

  config = {

    users.mutableUsers = cfg.mutable;
    
    users.users.${cfg.mainUser.name} = {
      isNormalUser = true;
      inherit (cfg.mainUser) extraGroups;
      inherit (cfg.mainUser) shell;
      initialPassword = lib.mkIf cfg.mutable "1234"; # to be changed on first login
      hashedPasswordFile = lib.mkIf (cfg.mainUser.passwordHashPath!=null) cfg.mainUser.passwordHashPath;
    };

  };
}