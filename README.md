# My NixOS Config

Assuming you place config to `~/nixos-config`.

## Rebuild

```bash
sudo nixos-rebuild switch --flake ~/nixos-config
```

## Update dependencies

```bash
sudo nixos-rebuild switch --flake ~/nixos-config
```

## Update emacs config

```bash
nix flake update emacs-config --flake ~/nixos-config
```
