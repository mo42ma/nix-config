{ config, lib, pkgs, ... }:
let
  cfg = config.homelib.k8stools;
  k8sCustomScripts = import ./scripts.nix { inherit config lib pkgs; };
in
{
  options.homelib.k8stools = {
    enable = lib.mkEnableOption "k8stools";
    minikube.enable = lib.mkEnableOption "minikube";
  };

  config = lib.mkIf cfg.enable {

    home.packages = with pkgs; [
      k8sCustomScripts
      kubectl
      openshift
      kubectx fzf # optional dependency for kubectx
      k9s
      jq
    ] ++ lib.optionals cfg.minikube.enable [
      minikube
      cilium-cli
      hubble
    ];

    programs.fish.shellAliases = {
      k = "kubectl";
      kx = "kubectx";
      kc = "kubectx --current";
      kn = "kubens";
      ocl = "oc login --web";
    };

  };
}
