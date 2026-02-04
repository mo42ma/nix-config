{ cfg, lib, pkgs, ... }:
let

  # just homeDiff
  # just hd "main"
  # just hd "origin/foobranch" "HEAD~87" "someConfigName"

  homeDiff = ''
    alias hd := homeDiff
    [script]
    homeDiff left='HEAD~1' right='HEAD' conf='${cfg.homeConfiguration}':
      rev_left=$(${lib.getExe pkgs.git} rev-parse {{left}})
      rev_right=$(${lib.getExe pkgs.git} rev-parse {{right}})
      echo "Comparing homeConfiguration {{conf}} between:"
      echo "left: {{left}} $rev_left"
      echo "right: {{right}} $rev_right"
      ${lib.getExe pkgs.nix-diff} \
        $(nix build --no-link --print-out-paths "git+file://${cfg.flakePath}?rev=$rev_left#homeConfigurations.{{conf}}.activationPackage") \
        $(nix build --no-link --print-out-paths "git+file://${cfg.flakePath}?rev=$rev_right#homeConfigurations.{{conf}}.activationPackage") \
  '';

  sysDiff = ''
    alias sd := sysDiff
    [script]
    sysDiff left='HEAD~1' right='HEAD' conf='${cfg.hostConfiguration}':
      rev_left=$(${lib.getExe pkgs.git} rev-parse {{left}})
      rev_right=$(${lib.getExe pkgs.git} rev-parse {{right}})
      echo "Comparing nixosConfiguration {{conf}} between:"
      echo "left: {{left}} $rev_left"
      echo "right: {{right}} $rev_right"
      ${lib.getExe pkgs.nix-diff} \
        $(nix build --no-link --print-out-paths "git+file://${cfg.flakePath}?rev=$rev_left#nixosConfigurations.{{conf}}.config.system.build.toplevel") \
        $(nix build --no-link --print-out-paths "git+file://${cfg.flakePath}?rev=$rev_right#nixosConfigurations.{{conf}}.config.system.build.toplevel") \
  '';

in

  lib.strings.concatStringsSep "\n" ([]
    ++ (lib.optionals (cfg.homeConfiguration != null) [ homeDiff ])
    ++ (lib.optionals (cfg.hostConfiguration != null) [ sysDiff ])
  )
