{ config, lib, pkgs, ... }:
let
  cfg = config.syslib.deploy;
  isDeployer = builtins.any (role: cfg.role == role) [ "deployer" "both" ];
  isManaged = builtins.any (role: cfg.role == role) [ "managed" "both" ];
in
{
  options.syslib.deploy = with lib; {
    enable = mkEnableOption "deploy-rs";
    role = mkOption {
      type = types.enum [ "deployer" "managed" "both" "none" ];
      description = "'deployer' has deploy-rs installed and 'managed' is a node that should be deployed to";
      default = "none";
    };
    connection = {
      url = mkOption {
        type = types.nullOr types.str;
        description = "url for deploy-rs";
        default = null;
      };
      sshUser = mkOption {
        type = types.nullOr types.str;
        description = "ssh user for deploy-rs";
        default = null;
      };
    };
  };

  config = lib.mkIf (cfg.role != "none") {

    assertions = [
      {
        assertion = isManaged -> cfg.connection.url != null && cfg.connection.sshUser != null;
        message = "define connection vars for deploy-rs";
      }
      {
        assertion = isManaged && cfg.connection.sshUser != "root" -> config.syslib.nix.remoteManaged;
        message = "config.syslib.nix.remoteManaged needs to be true for non-root ssh users";
      }
    ];

    environment.systemPackages = lib.mkIf isDeployer
      [ pkgs.deploy-rs ];

    # the actual config for "managed" nodes is in the deploy flake output
  };
}
