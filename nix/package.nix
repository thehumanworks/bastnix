{
  lib,
  buildGoModule,
  fetchFromGitHub,
  installShellFiles,
  makeBinaryWrapper,
  openssh,
  stdenv,
}:

buildGoModule (finalAttrs: {
  pname = "bast";
  version = "0.12.0";

  src = fetchFromGitHub {
    owner = "ellipse-software";
    repo = "bast";
    tag = "v${finalAttrs.version}";
    hash = "sha256-j34xMdBZPqH9zG22B4iOQrNZGXk6nqLjWSRC8hPY0vw=";
  };

  modRoot = "apps/bast";
  vendorHash = "sha256-fZ7NDQ7/RYwMI/v2I+j8CI6/OAigUegxCZ5fozcpxU4=";

  env.CGO_ENABLED = 0;

  ldflags = [
    "-s"
    "-w"
    "-X main.version=v${finalAttrs.version}"
  ];

  nativeBuildInputs = [
    installShellFiles
    makeBinaryWrapper
  ];

  nativeCheckInputs = [ openssh ];

  preCheck = ''
    export HOME="$(mktemp -d)"
    export BAST_NO_TELEMETRY=1
  '';

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    export HOME="$(mktemp -d)" BAST_NO_TELEMETRY=1
    installShellCompletion --cmd bast \
      --bash <($out/bin/bast completion bash) \
      --zsh <($out/bin/bast completion zsh) \
      --fish <($out/bin/bast completion fish)
    mkdir -p $out/share/nushell/vendor/autoload
    $out/bin/bast completion nushell > $out/share/nushell/vendor/autoload/bast.nu
  '';

  # Bast shells out to ssh, ssh-keygen and ssh-add. Append OpenSSH so a
  # user-provided ssh on PATH still wins.
  postFixup = ''
    wrapProgram $out/bin/bast --suffix PATH : ${lib.makeBinPath [ openssh ]}
  '';

  doInstallCheck = true;
  installCheckPhase = ''
    runHook preInstallCheck
    export HOME="$(mktemp -d)" BAST_NO_TELEMETRY=1
    $out/bin/bast --version | grep -F "v${finalAttrs.version}"
    $out/bin/bast --json hosts list | grep -F '"ok":true'
    runHook postInstallCheck
  '';

  meta = {
    description = "Browse SSH hosts, manage keys, and connect from the terminal";
    homepage = "https://bast.sh";
    changelog = "https://github.com/ellipse-software/bast/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    mainProgram = "bast";
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
  };
})
