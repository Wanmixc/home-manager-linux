# Arch Linux Setup with Nix + Home Manager

This guide sets up a new Arch Linux user, installs Nix using the official installer, enables flakes, installs Home Manager 25.11, and applies the Home Manager configuration.

## 1. Install required packages

Run as `root`:

```bash
pacman -Syu
pacman -S vim git curl
```

## 2. Create new user

Run as `root`:

```bash
useradd -m -G wheel -s /bin/bash wanmixc
passwd wanmixc
```

## 3. Enable sudo for wheel group

Run as `root`:

```bash
EDITOR=vim visudo -f /etc/sudoers
```

Find this line:

```text
# %wheel ALL=(ALL:ALL) ALL
```

Uncomment it, or add this line:

```text
%wheel ALL=(ALL:ALL) ALL
```

## 4. Install Nix

Run as user `wanmixc`, not as root:

```bash
curl -L https://nixos.org/nix/install | sh -s -- --daemon
```

After installation, log out and log in again.

## 5. Enable Nix flakes

Edit Nix config:

```bash
sudo vim /etc/nix/nix.conf
```

Add this line:

```text
experimental-features = nix-command flakes
```

Restart Nix daemon:

```bash
sudo systemctl restart nix-daemon
```

## 6. Add Home Manager 25.11 channels

Add Home Manager and Nixpkgs 25.11 channels:

```bash
nix-channel --add https://github.com/nix-community/home-manager/archive/release-25.11.tar.gz home-manager
nix-channel --add https://nixos.org/channels/nixos-25.11 nixpkgs
nix-channel --update
nix-shell '<home-manager>' -A install
```
After installation, log out and log in again.

## 7. Clone Home Manager configuration

Go to config directory:

```bash
cd ~/.config
mv home-manager home-manager.bak
git clone https://github.com/Wanmixc/home-manager-linux.git home-manager
cd home-manager
git switch vps
```

## 8. Create secrets file

Create `secrets.json`:

```bash
vim secrets.json
```

Add:

```json
{
  "github_token": "your github token"
}
```

## 9. Apply Home Manager configuration

Run:

```bash
home-manager switch
```

## 10. Set fish as default shell

Check fish path:

```bash
FISH_PATH="$(command -v fish)"
grep -qxF "$FISH_PATH" /etc/shells || echo "$FISH_PATH" | sudo tee -a /etc/shells
chsh -s "$FISH_PATH"
```
Log out and log in again.

Done.
