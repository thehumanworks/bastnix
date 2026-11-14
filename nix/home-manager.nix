{
  config,
  lib,
  pkgs,
  ...
}:

let
  shared = import ./options.nix { inherit lib pkgs; };
  cfg = config.programs.bast;
in
{
  options.programs.bast = shared.options // {
    enableSshIntegration = lib.mkOption {
      type = lib.types.bool;
      default = config.programs.ssh.enable;
      defaultText = lib.literalExpression "config.programs.ssh.enable";
      description = ''
        Add `Include ~/.ssh/bast/config` to the Home Manager generated
        `~/.ssh/config`. Bast prepends this line itself on first use, but a
        Home Manager managed `~/.ssh/config` is a read-only store symlink, so
        the Include has to come from Nix.
      '';
    };

    enableNushellIntegration = lib.mkOption {
      type = lib.types.bool;
      default = config.programs.nushell.enable;
      defaultText = lib.literalExpression "config.programs.nushell.enable";
      description = "Load Bast completions in Nushell.";
    };
  };

  config = lib.mkIf cfg.enable {
    # bash, zsh and fish pick up the completions shipped in the package.
    home.packages = [ cfg.package ];

    home.sessionVariables = shared.environment cfg;

    programs.ssh.includes = lib.mkIf cfg.enableSshIntegration [ "~/.ssh/bast/config" ];

    programs.nushell.extraConfig = lib.mkIf cfg.enableNushellIntegration ''
      source ${cfg.package}/share/nushell/vendor/autoload/bast.nu
    '';
  };
}
