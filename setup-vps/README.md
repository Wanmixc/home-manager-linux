# VPS First Setup - Arch Linux

Repository ini berisi script setup awal VPS berbasis **Arch Linux**.

Alur setup dibagi menjadi dua tahap:

1. `first-run.sh`  
   Dijalankan pertama kali sebagai `root`.

2. `second-run.sh`  
   Dijalankan setelah logout dari `root` dan login menggunakan user baru.

Script ini dibuat untuk kebutuhan VPS pribadi/homelab dengan target utama:

- Membuat user baru
- Set password user
- Memberikan akses sudo
- Disable root login SSH
- Install basic tools
- Install Nix
- Enable Nix flakes
- Install Home Manager `release-25.11`
- Clone konfigurasi Home Manager dari branch `vps`
- Menjalankan `home-manager switch`
- Install `udevil` dan `mergerfs` dari AUR tanpa `yay`
- Install dependency CasaOS
- Install CasaOS
- Kirim notifikasi status setup ke ntfy

> Script ini **tidak mengubah port SSH**. Port SSH tetap mengikuti konfigurasi VPS/provider.

---

## Struktur File

```text
setup-vps/
├── first-run.sh
├── second-run.sh
├── secrets-setup.example.json
├── secrets-setup.json
├── .gitignore
└── README.md
```

File yang boleh masuk repo publik:

```text
first-run.sh
second-run.sh
secrets-setup.example.json
.gitignore
README.md
```

File yang **jangan** di-commit:

```text
secrets-setup.json
```

Karena file tersebut berisi username, password, dan URL ntfy pribadi.

---

## Persiapan

Clone repository ini ke VPS atau upload manual file berikut:

```text
first-run.sh
second-run.sh
secrets-setup.example.json
```

Lalu copy file contoh config:

```bash
cp secrets-setup.example.json secrets-setup.json
```

Edit file config:

```bash
nano secrets-setup.json
```

Isi bagian berikut:

```json
{
  "new_user": {
    "username": "wanmixc",
    "password": "PasswordKamuYangKuat"
  },
  "ntfy": {
    "url": "https://ntfy.sh/topic-kamu"
  }
}
```

Contoh placeholder bawaan:

```json
{
  "new_user": {
    "username": "__CHANGE_ME_USERNAME__",
    "password": "__CHANGE_ME_PASSWORD__"
  },
  "ntfy": {
    "url": "__CHANGE_ME_NTFY_URL__"
  }
}
```

Jika nilai masih placeholder, script akan berhenti dan meminta kamu mengubah file config terlebih dahulu.

---

## File `.gitignore`

Gunakan `.gitignore` berikut agar file rahasia tidak ikut masuk repo publik:

```gitignore
secrets-setup.json
logs/
aur-build/
```

---

## Tahap 1 - Jalankan `first-run.sh` sebagai root

Login pertama kali ke VPS sebagai `root`.

Pastikan file ini ada di folder kerja:

```text
first-run.sh
second-run.sh
secrets-setup.json
```

Beri permission execute:

```bash
chmod +x first-run.sh second-run.sh
```

Jalankan script pertama:

```bash
./first-run.sh
```

Script pertama akan melakukan:

- Install basic tools
- Membuat user baru
- Set password user baru
- Menambahkan user ke grup `wheel`
- Mengaktifkan sudo untuk grup `wheel`
- Membuat folder:

```text
/home/<username>/Extra/setup_vps
```

- Menyalin file berikut ke folder user baru:

```text
first-run.sh
second-run.sh
secrets-setup.json
```

Setelah selesai, masuk ke user baru:

```bash
su - <username>
```

Contoh:

```bash
su - wanmixc
```

---

## Tahap 2 - Jalankan `second-run.sh` sebagai user baru

Masuk ke folder setup:

```bash
cd ~/Extra/setup_vps
```

Jalankan script kedua:

```bash
./second-run.sh
```

Script kedua akan melakukan:

### 1. Install basic tools

Beberapa package utama yang diinstall:

```text
sudo
openssh
git
curl
wget
base-devel
nano
vim
htop
btop
unzip
zip
jq
ufw
fail2ban
pacman-contrib
ncdu
iotop
lsof
bind-tools
traceroute
rsync
restic
rclone
smartmontools
hdparm
parted
gptfdisk
e2fsprogs
xfsprogs
btrfs-progs
nfs-utils
cifs-utils
etckeeper
```

### 2. Disable root login SSH

Script akan membuat konfigurasi:

```sshconfig
PermitRootLogin no
PasswordAuthentication yes
KbdInteractiveAuthentication yes
UsePAM yes
PubkeyAuthentication yes
```

Script **tidak mengubah port SSH**.

### 3. Setup UFW dan fail2ban

Script akan mengaktifkan:

```text
ufw
fail2ban
paccache.timer
```

UFW akan membuka rule `OpenSSH`.

### 4. Install Nix

Nix diinstall melalui `pacman`:

```bash
sudo pacman -S --needed nix
```

Lalu mengaktifkan:

```text
nix-command
flakes
```

Pada file:

```text
/etc/nix/nix.conf
```

### 5. Install Home Manager

Home Manager diinstall menggunakan branch:

```text
release-25.11
```

Script memakai channel:

```text
nixos-25.11
home-manager release-25.11
```

### 6. Clone konfigurasi Home Manager

Repo yang digunakan sudah di-hardcode di script:

```text
https://github.com/Wanmixc/home-manager-linux.git
```

Branch:

```text
vps
```

Target folder:

```text
~/.config/home-manager
```

Jika folder lama sudah ada, akan dibackup menjadi:

```text
~/.config/home-manager.backup.<tanggal>
```

### 7. Jalankan `home-manager switch`

Script akan menjalankan:

```bash
home-manager switch
```

Jika gagal, script tetap lanjut ke tahap AUR dan CasaOS, tetapi status akan dikirim ke ntfy.

### 8. Install `udevil` dan `mergerfs` dari AUR tanpa yay

Script tidak menggunakan `yay`.

Package AUR akan di-clone manual:

```bash
git clone https://aur.archlinux.org/udevil.git
git clone https://aur.archlinux.org/mergerfs.git
```

Lalu diinstall dengan:

```bash
makepkg -si --needed --noconfirm
```

Folder build berada di:

```text
~/Extra/setup_vps/aur-build
```

### 9. Install dependency CasaOS

Dependency CasaOS yang diinstall:

```text
wget
curl
smartmontools
ntfs-3g
net-tools
samba
apparmor
docker
parted
cifs-utils
unzip
docker-compose
rclone
```

Docker akan diaktifkan:

```bash
sudo systemctl enable --now docker
```

User aktif akan ditambahkan ke grup docker:

```bash
sudo usermod -aG docker <username>
```

Setelah script selesai, logout-login ulang agar grup docker aktif.

### 10. Install CasaOS

CasaOS langsung diinstall tanpa prompt tambahan.

Script akan download installer:

```bash
curl -fsSL https://get.casaos.io -o /tmp/casaos-install-<tanggal>.sh
```

Lalu menjalankan installer tersebut.

### 11. Backup konfigurasi penting

Backup akan disimpan ke:

```text
~/Extra/backup-config/<tanggal>
```

Yang dibackup:

```text
/etc/ssh
/etc/nix
~/.config/home-manager
```

Script juga menjalankan `etckeeper` untuk tracking `/etc`.

---

## Notifikasi ntfy

Script akan mengirim notifikasi ke URL ntfy dari `secrets-setup.json`.

Contoh:

```json
{
  "ntfy": {
    "url": "https://ntfy.sh/topic-kamu"
  }
}
```

Event yang dikirim:

- Setup dimulai
- SSH hardening berhasil
- Nix berhasil
- Home Manager install berhasil
- Home Manager switch berhasil/gagal
- Install AUR package berhasil
- Docker group berhasil/gagal
- CasaOS berhasil/gagal
- Setup selesai
- Setup gagal di step tertentu

---

## Setelah Script Selesai

Logout dan login ulang user:

```bash
exit
```

Lalu login kembali.

Cek akses sudo:

```bash
sudo whoami
```

Output yang benar:

```text
root
```

Cek Docker:

```bash
docker ps
```

Cek Nix:

```bash
nix --version
```

Cek Home Manager:

```bash
home-manager --version
```

Cek SSH config aktif:

```bash
sudo sshd -T | grep -E '^(port|permitrootlogin|passwordauthentication|usepam)'
```

Output yang diharapkan:

```text
permitrootlogin no
passwordauthentication yes
usepam yes
```

---

## Catatan SSH dan NAT VPS

Script ini tidak mengubah port SSH.

Jika VPS kamu berada di balik NAT provider, public IP bisa berbeda dengan IP interface VPS.

Cek IP publik:

```bash
curl -4 ifconfig.me
```

Cek IP interface VPS:

```bash
ip -4 addr
```

Jika IP publik tidak muncul di interface, berarti VPS memakai NAT/provider gateway.

Untuk akses SSH dari luar, minta provider membuat port forwarding, misalnya:

```text
External IP   : IP publik provider
External Port : 9898
Internal IP   : IP private VPS
Internal Port : 22
Protocol      : TCP
```

Atau jika SSH di VPS memang listen di port 9898:

```text
External Port : 9898
Internal Port : 9898
Protocol      : TCP
```

---

## Troubleshooting

### Password user benar di localhost, tapi salah dari luar

Cek fingerprint SSH:

```bash
ssh-keyscan -p 22 -t ed25519 127.0.0.1 2>/dev/null | ssh-keygen -lf -
ssh-keyscan -p 22 -t ed25519 <PUBLIC_IP> 2>/dev/null | ssh-keygen -lf -
```

Jika fingerprint berbeda, public IP tersebut tidak mengarah ke SSH server VPS yang sama.

### Cek log SSH

```bash
sudo journalctl -u sshd -f
```

Jika login dari luar tidak muncul di log, berarti koneksi tidak sampai ke SSH server VPS.

### Cek service SSH

```bash
sudo systemctl status sshd --no-pager
sudo ss -ltnp | grep sshd
```

### Cek firewall lokal

```bash
sudo ufw status verbose
sudo iptables -S
sudo nft list ruleset
```

### Cek Nix daemon

```bash
sudo systemctl status nix-daemon --no-pager
```

### Cek CasaOS

```bash
systemctl status casaos --no-pager
```

Jika service berbeda, cek daftar service:

```bash
systemctl list-units | grep -i casa
```

---

## Keamanan

Jangan commit file ini:

```text
secrets-setup.json
```

Karena berisi:

- Username
- Password
- URL ntfy pribadi

Jika tidak sengaja ter-commit:

1. Hapus dari repo
2. Rotate/ganti password VPS
3. Ganti topic ntfy
4. Bersihkan history git jika repo sudah public

---

## Perintah Singkat

```bash
cp secrets-setup.example.json secrets-setup.json
nano secrets-setup.json

chmod +x first-run.sh second-run.sh

# Jalankan sebagai root
./first-run.sh

# Masuk user baru
su - <username>

# Jalankan sebagai user baru
cd ~/Extra/setup_vps
./second-run.sh
```
