# Options shared by the Home Manager and NixOS modules.
{ lib, pkgs }:

let
  inherit (lib) mkEnableOption mkOption types;
in
{
  options = {
    enable = mkEnableOption "Bast, a terminal UI and CLI for SSH hosts and keys";

    package = mkOption {
      type = types.package;
      default = pkgs.bast or (pkgs.callPackage ./package.nix { });
      defaultText = lib.literalExpression "pkgs.bast or (pkgs.callPackage ./package.nix { })";
      description = "The Bast package to install.";
    };

    telemetry.enable = mkOption {
      type = types.bool;
      default = true;
      description = ''
        Whether Bast may send anonymous usage telemetry and offer error reports.
        Setting this to `false` exports `BAST_NO_TELEMETRY=1`.
      '';
    };

    sync.enable = mkOption {
      type = types.bool;
      default = true;
      description = ''
        Whether cloud inventory sync (GCP, AWS, Azure, Hetzner, ...) is available.
        Setting this to `false` exports `BAST_NO_SYNC=1`.
      '';
    };

    vault = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = ''
          Whether end-to-end encrypted Vault sync is available.
          Setting this to `false` exports `BAST_NO_VAULT=1`.
        '';
      };

      apiBase = mkOption {
        type = types.nullOr types.str;
        default = null;
        example = "https://vault.example.com";
        description = ''
          Vault API origin for a self-hosted Bast web app. Exported as
          `BAST_VAULT_API`, which overrides the base saved in
          `~/.config/bast/vault-session.json`.
        '';
      };
    };

    onboarding.enable = mkOption {
      type = types.bool;
      default = true;
      description = ''
        Whether to show the first-launch screen when no hosts exist.
        Setting this to `false` exports `BAST_NO_ONBOARDING=1`.
      '';
    };

    nerdFont = mkOption {
      type = types.nullOr types.bool;
      default = null;
      description = ''
        Force Nerd Font glyphs on (`true`) or off (`false`) via `BAST_NERD_FONT`.
        `null` lets Bast detect it.
      '';
    };

    shell = mkOption {
      type = types.nullOr types.str;
      default = null;
      example = lib.literalExpression ''"''${pkgs.zsh}/bin/zsh"'';
      description = ''
        Local shell the Files view opens. Exported as `BAST_SHELL`;
        Bast falls back to `$SHELL` when unset.
      '';
    };
  };

  # Bast treats any non-empty BAST_NO_* value as "disabled", so only set them
  # when a feature is turned off.
  environment =
    cfg:
    lib.optionalAttrs (!cfg.telemetry.enable) { BAST_NO_TELEMETRY = "1"; }
    // lib.optionalAttrs (!cfg.sync.enable) { BAST_NO_SYNC = "1"; }
    // lib.optionalAttrs (!cfg.vault.enable) { BAST_NO_VAULT = "1"; }
    // lib.optionalAttrs (!cfg.onboarding.enable) { BAST_NO_ONBOARDING = "1"; }
    // lib.optionalAttrs (cfg.vault.apiBase != null) { BAST_VAULT_API = cfg.vault.apiBase; }
    // lib.optionalAttrs (cfg.nerdFont != null) { BAST_NERD_FONT = if cfg.nerdFont then "1" else "0"; }
    // lib.optionalAttrs (cfg.shell != null) { BAST_SHELL = cfg.shell; };
}
