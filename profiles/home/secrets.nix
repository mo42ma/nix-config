{ config, lib, cfglib, userConfig, ... }:
let
  cfg = config.profiles.secrets;
in
{
  options.profiles.secrets = with lib; {
    enable = mkEnableOption "tools required to use secrets in homeConfigurations";
    secrets = mkOption { type=types.attrs; default = {}; description="config.sops.secrets"; };
  };

  config = lib.mkIf cfg.enable {

    homelib = {
      gpg.enable = lib.mkDefault true;
      sops = {
        enable = lib.mkDefault true;
        secrets = lib.mkDefault cfg.secrets;
        userSopsFile = cfglib.paths.userSecretsFile userConfig.userName;
      };
      bitwarden.enable = lib.mkDefault true;
    };

  };

}
