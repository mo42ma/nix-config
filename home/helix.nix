{ config, lib, pkgs, ...}:
let
  cfg = config.homelib.helix;
in
{
  options.homelib.helix = with lib; {
    enable = mkEnableOption "helix editor";
    clipboardPkg = mkOption {
      type = types.nullOr types.package;
      default = null;
      example = "pkgs.wl-clipboard";
    };
  };

  config = lib.mkIf cfg.enable {

    home.packages = with pkgs; [
      helix
      nixd
    ] ++ lib.optionals (cfg.clipboardPkg != null) [ cfg.clipboardPkg ];

    programs.helix = {
      enable = true;
      defaultEditor = true;

      # https://theari.dev/blog/enhanced-helix-config/
      settings = {

        # not managed by stylix because the built-in guvbox variant is better.
        # could aslo use without transform but there is no guvbox_dark_medium
        theme = with builtins; head (
          split "_" config.lib.stylix.colors.scheme-slug-underscored
        );

        editor = {
          # Show currently open buffers, only when more than one exists.
          bufferline = "multiple";
          # Highlight all lines with a cursor
          cursorline = true;
          # Show a ruler at column 120
          rulers = [ 120 ];
          # Force the theme to show colors
          true-color = true;
          # Minimum severity to show a diagnostic after the end of a line
          end-of-line-diagnostics = "hint";

          trim-trailing-whitespace = true;
          trim-final-newlines = true;

          # dont place pairs of (){}[]''""``
          auto-pairs = false;

          auto-save = {
            focus-lost = true;
            after-delay = {
              enable = true;
              timeout = 1500; # ms
            };
          };

          # different shapes per mode
          cursor-shape = {
            insert = "bar";
            normal = "block";
            select = "underline";
          };

          indent-guides = {
            character = "╎";
            render = true;
            skip-levels = 1;
          };

          lsp = {
            auto-signature-help = true;
            # Show LSP messages in the status line
            display-messages = true;
          };

          statusline = {
            left = [
              "mode"
              "spinner"
              "version-control"
              "file-name"
              "read-only-indicator"
              "file-modification-indicator"
            ];
          };

          inline-diagnostics = {
            cursor-line = "error"; # Show inline diagnostics when the cursor is on the line
            other-lines = "disable"; # Don't expand diagnostics unless the cursor is on the line
          };

          file-picker.hidden = false;
        };

        keys = {
          normal = {
            A-x = "extend_to_line_bounds";
            X = "select_line_above";

            # buffer navigaion
            "A-," = "goto_previous_buffer";
            "A-." = "goto_next_buffer";
            "A-q" = ":buffer-close";
            "A-/" = "repeat_last_motion";

            # lazygit integration
            C-g = [
              ":write-all"
              ":new"
              ":insert-output ${lib.getExe pkgs.lazygit}"
              ":buffer-close!"
              ":redraw"
              ":reload-all"
            ];

          # git blame workaround until #13133 is merged
          space.b =
            ":sh git blame -L %{cursor_line},%{cursor_line} %{buffer_name}";

          };

          select = {
            A-x = "extend_to_line_bounds";
            X = "select_line_above";
          };

        };
      };

    };
  };
}
