{ pkgs, lib, ... }:
let
  pickBranch = pkgs.writeShellApplication {
    name = "pickbranch";
    runtimeInputs = with pkgs; [ git coreutils gawk fzf ];
    text = ''
      format_ref='%(align:30)%(color:magenta)%(refname:short)%(end)'
      format_cdate='%(align:20)%(color:bold green)%(committerdate:relative)%(end)'
      format_subject='%(align:70)%(color:white)%(subject)%(end)'
      format_author='%(align:18)%(color:magenta)%(authorname)%(color:reset)%(end)'
      git for-each-ref --sort=-committerdate --color=always refs/heads \
        --format="$format_ref | $format_cdate | $format_subject | $format_author" \
      | fzf --ansi --layout=reverse --height=25% \
      | awk -F "|" '{ print $1 }' \
      | tr -d ' '
    '';
  };

  pickCommitFromBranch = pkgs.writeShellApplication {
    name = "pickCommitFromBranch";
    runtimeInputs = with pkgs; [ git gawk fzf ];
    text = ''
      format="%C(magenta)%h %C(auto)%d %Creset%C(bold white)%s %C(green)%cr %C(blue)[%an]"
      git log --color=always --abbrev-commit -30 main~1..HEAD --pretty=format:"$format" \
      | fzf --ansi --layout=reverse --height=25% \
      | awk -F " " '{ print $1 }'
    '';
  };
  logFormat = ''--pretty=format:"%C(magenta)%h%Creset -%C(red)%d%Creset %s %C(dim green)(%cr) [%an]"'';
in
{
  gl = "config --global -l";
  reporoot = "rev-parse --show-toplevel";
  s = "status -sb";
  st = "status";
  sh = "show";
  shp = "! git sh $(${lib.getExe pickCommitFromBranch})";
  aa = "add --all";
  aac = "!git add --all; git commit --message";
  c = "commit --message";
  cf = "commit --fixup";
  cfp = "! git cf $(${lib.getExe pickCommitFromBranch})";
  cp = "cherry-pick";
  ca = "commit --amend";
  can = "commit --amend --no-edit";
  co = "checkout";
  com = "checkout main";
  comc = "!git add --all; git commit -m \"pop\"; git checkout main";
  cob = "checkout -b";
  sw = "switch";
  sp = ''!git switch "$(${lib.getExe pickBranch})"'';
  ds = "diff --staged";
  del = "branch -d";
  delf = "branch -D";
  delr = ''!f() { git push origin :''${1:?no branch name given}; }; f'';
  delfr = ''!f() { git delr ''${1}; git delf $1; }; f'';
  br = "branch --format='%(HEAD) %(color:yellow)%(refname:short)%(color:reset) - %(contents:subject) %(color:green)(%(committerdate:relative)) [%(authorname)]' --sort=-committerdate";
  pb = "!${lib.getExe pickBranch}";
  bclean = ''!f() { git branch --merged ''${1-main} | grep -v " ''${1-main}$" | xargs -r git branch -d; }; f'';
  lg = "!git log ${logFormat} --abbrev-commit -30 -n";
  l = "lg 5";
  ll = "lg 10";
  lm = "!git log ${logFormat} --abbrev-commit -30 main~1..HEAD";
  lb = ''!f() { git log ${logFormat} ''${1:?no branch name given}..$(git branch --show-current); }; f'';
  lp = "! ${lib.getExe pickCommitFromBranch}";
  rb = "rebase";
  rbm = "rebase main";
  rbi = "rebase -i";
  rbip = "! git rbi $(${lib.getExe pickCommitFromBranch})";
  rbim = "rebase -i main";
  rbc = "rebase --continue";
  rba = "rebase --abort";
  rhh = "reset --hard HEAD";
  pop = "reset HEAD~1 --mixed";
  popf = "reset HEAD~1 --hard";
  ps = "push";
  psf = "push --force-with-lease";
  pl = "pull";
  m = "merge";
  md = ''!f() { git merge --ff-only ''${1?no branch name given} && git branch -d ''${1?no branch name given}; }; f'';
  ms = "merge --squash";
  mc = "merge --continue";
  ma = "merge --abort";
  bis = "bisect start";
  big = "bisect good";
  bib = "bisect bad";
  bir = "bisect reset";
  gone-check = ''! git fetch -p && git for-each-ref --format '%(refname:short) %(upstream:track)' | awk '$2 == \"[gone]\" {print $1}' '';
  gone-clean = ''! git fetch -p && git for-each-ref --format '%(refname:short) %(upstream:track)' | awk '$2 == \"[gone]\" {print $1}' | xargs -r git branch -D'';
  unstage = "! git restore --staged $(git reporoot)";
}
