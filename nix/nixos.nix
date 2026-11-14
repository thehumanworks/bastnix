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
  options.programs.bast = shared.options;

  config = lib.mkIf cfg.enable {
    # Completions under share/ are linked into the system profile for
    # bash, zsh and fish.
    environment.systemPackages = [ cfg.package ];
    environment.variables = shared.environment cfg;
  };
}
