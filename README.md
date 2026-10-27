# hylki-flake

A Nix flake for [Hylki](https://github.com/hyprlab/hylki), a clean, fast
GNOME-native email client, on x86_64 and aarch64 Linux. It packages the latest
upstream release.

## Usage

Run it without installing:

```sh
nix run github:clementpoiret/hylki-flake
```

To install it on NixOS, add the flake to your system flake's inputs:

```nix
inputs.hylki.url = "github:clementpoiret/hylki-flake";
```

Pass `inputs` to your modules with `specialArgs = { inherit inputs; };`, then
add the package in your NixOS configuration:

```nix
{ inputs, pkgs, ... }:
{
  environment.systemPackages = [
    inputs.hylki.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];
}
```

Password storage needs a Secret Service provider. GNOME already enables
GNOME Keyring; on other desktops, enable `services.gnome.gnome-keyring.enable`
or configure another provider. Evolution Data Server is optional for external
address books (`services.gnome.evolution-data-server.enable = true;`).

The easiest way to connect mail accounts may be through GNOME Online
Accounts: Hylki imports them without asking for server settings again, and
Gmail and Microsoft accounts sign in through it. GNOME sets this up already.
On other desktops, enable the accounts daemon and the keyring:

```nix
services.gnome = {
  gnome-online-accounts.enable = true;
  gnome-keyring.enable = true;
};
```

Then add your accounts in GNOME Settings, which outside GNOME has to be told
it is running there (it comes from `pkgs.gnome-control-center`):

```sh
XDG_CURRENT_DESKTOP=GNOME gnome-control-center online-accounts
```

## Updates

The packaged release is the tag in the `hylki-src` input of `flake.nix`. Once
a day, CI looks up upstream's latest release (prereleases excluded). If it is
not the pinned one, CI builds it and runs its tests on x86_64 and aarch64, and
commits the new pin when both pass. A failing release is not committed, and
CI tries again the next day.

The version and the Rust dependencies come from the release's `Cargo.toml` and
`Cargo.lock`, so there is no Cargo hash to maintain. To pin a release by hand,
change the tag in `flake.nix`, then:

```sh
nix flake update hylki-src
nix flake check --print-build-logs
```

`nix flake update nixpkgs` moves nixpkgs forward.
