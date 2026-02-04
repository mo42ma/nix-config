{ pkgs }:

{
  files= {
    autoSave = "afterDelay";
    autoSaveDelay = 1500;
    trimTrailingWhitespace = true;

    associations = {
      "*.yaml.j2" = "yaml";
      "*.yml.j2" = "yaml";
    };
  };

  diffEditor.ignoreTrimWhitespace = false;

  # https://github.com/nix-community/vscode-nix-ide
  nix = {
    enableLanguageServer = true;
    serverPath = "${pkgs.nixd}/bin/nixd";
  };
}