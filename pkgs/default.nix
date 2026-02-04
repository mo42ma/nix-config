{ pkgs, ... }:
{
  invhosts = pkgs.callPackage ./invhosts.nix {};
}
