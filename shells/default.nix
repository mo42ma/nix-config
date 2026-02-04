{ system, self }:
let
  pkgs_23_05 = import self.inputs.nixpkgs-23-05 { inherit system; };
in rec {
  default = ansible;
  ansible = import ./ansible.nix { pkgs = pkgs_23_05; inherit self system; };
}