{ config, lib, ... }:
let
  cfg = config.syslib.localization;
in
{
  options.syslib.localization = with lib; {
    enable = mkEnableOption "localization";
    timezone = mkOption { type = types.str; };
    locale = mkOption { type = types.str; };
    keymap = mkOption { type = types.str; };
  };

  config = lib.mkIf cfg.enable {
    time.timeZone = cfg.timezone;
    i18n.defaultLocale = cfg.locale;
    console.keyMap = cfg.keymap;
  };
}