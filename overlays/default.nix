_:
let
  # get patch file: git format-patch -1 <ref>
  patchPkg = pkg: patches:
    pkg.overrideAttrs (prev: {
      patches = (prev.patches or []) ++ patches;
    });
in
rec {

  default = final: prev:
    (additions final prev) //
    (modifications final prev);

  # packages defined in this flake
  additions = _: prev: {
    invhosts = prev.callPackage ../pkgs/invhosts.nix {};
  };

  # changes to existing pkgs from nixpkgs
  modifications = final: prev: {
    swaylock-effects = patchPkg prev.swaylock-effects [ ./swaylock-effects-graceperiod.patch ];
  };
}
