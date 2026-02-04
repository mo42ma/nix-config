# NixOS config
This is the config of my personal desktop linux systems (not yet ready to switch my homelab to nix). I'm using this on my main laptop as my daily driver. Nix allows me to have all the configs as code so I dont forget them. Due to its nature it also is very reproducible.

## Structure
### flake.nix
- entrypoint
- declares external dependencies
### system/home
- place for system-wide or /home-level nix modules
- defines interfaces for single builing blocks/packages/tools
### hosts
- contains host-specific info (i.e. hardware-configuration)
- defines which modules from home/syslib are used on the specific hosts
### users
- declares values specific to a user instead of a host
- shared between home- and syslib -> single source of truth

## Install
>[!NOTE]
> In case you want to use this as starting point, it's probably best to fork this repo or to just take the pieces you want. I have no intentions on supporting your needs in here, but I'm happy to answer your questions
- Boot into (minimal) NixOS live iso
- Use either [partition.sh](partition.sh) or [bootstrap.sh](bootstrap.sh) # WARN: This wipes your disk
- nix-shell -p git
- git clone \<repo url>
- create a host entry like [hosts/t14](hosts/t14/configuration.nix)
- add the path to the host config to [flake.nix](flake.nix)
- nixos-generate-config --show-hardware-config --root /mnt > hosts/\<name>/hardware-configurtation.nix
- git add hosts/\<name>/hardware-configurtation.nix flake.nix
- nixos-install --flake .#\<name>
- reboot
- apply home-manager config # may be possible with nixos-enter in the live iso, but I didnt test that yet


### Thanks to
- [maximbaz](https://github.com/maximbaz) arch config I studied extensively when I began to build my own configs
- [vimjoyer](https://github.com/vimjoyer/nixconf) and [librephoenix](https://github.com/librephoenix/nixos-config) for their nice youtube videos about nix and ofc the configs

