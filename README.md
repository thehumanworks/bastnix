# bastnix

Nix package, Home Manager module and NixOS module for [Bast](https://bast.sh), the SSH host and key manager.

| Output | Description |
| --- | --- |
| `packages.<system>.bast` / `default` | Bast built from source (v0.12.0), with bash/zsh/fish/nushell completions; OpenSSH is appended to `PATH` |
| `overlays.default` | Adds `pkgs.bast` |
| `homeManagerModules.default` (alias `homeModules`) | `programs.bast` for Home Manager |
| `nixosModules.default` | `programs.bast` for NixOS (system-wide install + environment) |

## Flake input

```nix
inputs.bast.url = "github:thehumanworks/bastnix";
inputs.bast.inputs.nixpkgs.follows = "nixpkgs";
```

Try it without installing: `nix run .#bast`.

## Home Manager

```nix
{
  imports = [ inputs.bast.homeManagerModules.default ];

  programs.ssh.enable = true;
  programs.bast = {
    enable = true;
    telemetry.enable = false;                      # BAST_NO_TELEMETRY=1
    # vault.apiBase = "https://vault.example.com"; # BAST_VAULT_API (self-hosted Vault)
  };
}
```

When `programs.ssh.enable` is on, the module adds `Include ~/.ssh/bast/config` at the top of the generated `~/.ssh/config`. Home Manager makes that file a read-only symlink, so Bast can't add the line itself. Bast detects the Include and leaves the file alone. Hosts you add in Bast go to `~/.ssh/bast/config`, which stays mutable. Without Home Manager's ssh module, Bast adds the Include itself on first use.

## NixOS

```nix
{
  imports = [ inputs.bast.nixosModules.default ];
  programs.bast = {
    enable = true;
    telemetry.enable = false;
  };
}
```

On NixOS, zsh and fish completions are linked only when `programs.zsh.enable` / `programs.fish.enable` is set. Bash completions work without extra setup.

## Options (both modules)

| Option | Default | Effect |
| --- | --- | --- |
| `enable` | `false` | Install Bast |
| `package` | `pkgs.bast` or the bundled package | Package to use |
| `telemetry.enable` | `true` | `false` → `BAST_NO_TELEMETRY=1` |
| `sync.enable` | `true` | `false` → `BAST_NO_SYNC=1` (cloud inventory sync) |
| `vault.enable` | `true` | `false` → `BAST_NO_VAULT=1` |
| `vault.apiBase` | `null` | `BAST_VAULT_API` |
| `onboarding.enable` | `true` | `false` → `BAST_NO_ONBOARDING=1` |
| `nerdFont` | `null` (auto) | `BAST_NERD_FONT=1/0` |
| `shell` | `null` | `BAST_SHELL` (shell opened by the Files view) |

Home Manager only: `enableSshIntegration` (defaults to `programs.ssh.enable`) and `enableNushellIntegration` (defaults to `programs.nushell.enable`).

Bast treats any non-empty `BAST_NO_*` value as "off", so the modules set these variables only to disable a feature.

## Notes

- Bast keeps mutable state in `~/.ssh/bast/` and `~/.config/bast/` (keys, tokens, metadata). The modules don't manage these directories.
- `bast update` refuses to run on Nix builds because there is no installer receipt. To update, bump `version`, `hash` and `vendorHash` in `nix/package.nix`.
- The self-hosted Vault web app (`apps/web`, Next.js on Bun, backed by Upstash, R2 and Cloudflare Email) is not packaged.
