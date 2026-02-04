{ self, ... }:
let
  inherit (self.inputs.nixpkgs) lib;

  pkgsFor = nixpkgs: system:
    import nixpkgs { inherit system; };
  homeConfigName = user: host: "${user}@${host}";
  optionalConfigFile = path:
    lib.optionals (lib.pathExists path) [ path ];

  cfgPaths =
  let
    nixosModules = ./system;
    systemProfiles = ./profiles/system;
    homeProfiles = ./profiles/home;
    hmModules = ./home;
    userConfigDir = ./users;
    hostConfigDir = ./hosts;
  in {
    inherit nixosModules systemProfiles homeProfiles hmModules userConfigDir hostConfigDir;
    hostConfigFile = host: hostConfigDir + "/${host}/configuration.nix";
    hostSecretsFile = host: hostConfigDir + "/${host}/secrets.yaml";
    diskConfigFile = host: hostConfigDir + "/${host}/disko.nix";
    hardwareConfigFile = host: hostConfigDir + "/${host}/hardware-configuration.nix";
    homeConfigFile = host: hostConfigDir + "/${host}/home.nix";
    userConfigFile = user: userConfigDir + "/${user}.nix";
    userSecretsFile = user: userConfigDir + "/${user}.secrets.yaml";
  };

  # get modules below $dir even if they are in a directory (non-recursive)
  nixModulesIn = with builtins; dir:
  let
    # i.e. $dir/foo.nix, $dir/bar.nix
    flatModuleFilter = base: name: type:
      if type == "regular" && (lib.hasSuffix ".nix" name) && (name != "default.nix")
      then base + ("/" + name)
      else null;
    # i.e. $dir/foo/default.nix, $dir/bar/default.nix
    dirModuleFilter = base: name: type:
      if type == "directory" && (pathExists (base + "/${name}" + "/default.nix"))
      then base + "/${name}"
      else null;

    modules = moduleFileFilter: dir:
      lib.filter (val: val != null)
      (lib.mapAttrsToList (moduleFileFilter dir) (readDir dir));
    flatModules = dir: modules flatModuleFilter dir;
    dirModules = dir: modules dirModuleFilter dir;
  in
    (flatModules dir) ++ (dirModules dir);

  cfglib = {
    inherit nixModulesIn;
    paths = cfgPaths;
  };
 in
{

  forEachSystem = self.inputs.nixpkgs.lib.genAttrs [
    "x86_64-linux" "aarch64-darwin"
  ];

  mkSystem = system: hostConfig: user: pkgSource:
    pkgSource.lib.nixosSystem {
      specialArgs = {
        inherit (self) inputs outputs;
        nixpkgs-stable = pkgsFor self.inputs.nixpkgs system;
        nixpkgs-unstable = pkgsFor self.inputs.nixpkgs-unstable system;
        inherit hostConfig cfglib;
        userConfig = import (cfglib.paths.userConfigFile user) {};
      };
      modules = [
        cfglib.paths.nixosModules
        self.inputs.disko.nixosModules.default
        (cfglib.paths.hostConfigFile hostConfig)
        self.inputs.sops-nix.nixosModules.default
        cfglib.paths.systemProfiles
        self.inputs.stylix.nixosModules.default
      ]
      ++ optionalConfigFile (cfglib.paths.hardwareConfigFile hostConfig)
      ++ optionalConfigFile (cfglib.paths.diskConfigFile hostConfig)
      ++ [ (_: { nixpkgs.overlays = [ self.outputs.overlays.default ]; }) ];
    };

  mkHome = system: hostConfig: user: hmSource:
    hmSource.lib.homeManagerConfiguration {
      pkgs = import hmSource.inputs.nixpkgs { inherit system; };
      extraSpecialArgs = {
        inherit (self) inputs outputs;
        nixpkgs-stable = pkgsFor self.inputs.nixpkgs system;
        nixpkgs-unstable = pkgsFor self.inputs.nixpkgs-unstable system;
        inherit cfglib;
        homeConfig = homeConfigName user hostConfig;
        sysConfig = hostConfig;
        userConfig = import (cfglib.paths.userConfigFile user) {};
      };
      modules = [
        cfglib.paths.hmModules
        cfglib.paths.homeProfiles
        (cfglib.paths.homeConfigFile hostConfig)
        self.inputs.sops-nix.homeManagerModules.sops
        self.inputs.stylix.homeModules.default
        (_: { nixpkgs.overlays = [ self.outputs.overlays.default ]; })
      ];
    };

    mkDeployNode = _: config: {
      hostname = config.config.syslib.deploy.connection.url;
      profiles.system = {
        user = "root"; # the adminuser smh doesnt work despite being nix trusted user and having passwordless sudo
        sshUser = config.config.syslib.deploy.connection.sshUser;
        path = self.inputs.deploy-rs.lib."x86_64-linux".activate.nixos config;
      };
    };

}
