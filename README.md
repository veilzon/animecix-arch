# AnimeciX Arch Linux deposu

AnimeciX için imzalı Arch Linux pacman deposu.

## Kurulum

Tek komut:

```bash
curl -fsSL https://veilzon.github.io/animecix-arch/install.sh -o /tmp/animecix-install.sh
sudo bash /tmp/animecix-install.sh
```

Veya doğrudan:

```bash
curl -fsSL https://veilzon.github.io/animecix-arch/install.sh | sudo bash
```

Manuel kurulum:

```bash
curl -fsSL https://veilzon.github.io/animecix-arch/animecix.gpg -o /tmp/animecix.gpg
sudo pacman-key --add /tmp/animecix.gpg
sudo pacman-key --lsign-key 2B2361F1C5D588EF

# /etc/pacman.conf dosyasına ekle
[animecix]
SigLevel = Required DatabaseOptional
Server = https://veilzon.github.io/animecix-arch/$arch

sudo pacman -Syu
sudo pacman -S animecix
```

Güncelleme:

```bash
sudo pacman -Syu
```

## Paket

- `animecix`: kaynak paket; GitHub `v*` tag tarball'ından CI'da derlenir.
- Paketler ve veritabanı ayrı bir GPG anahtarıyla imzalanır.
- Anahtar parmak izi: `7A08 1AF6 3552 C10A 13BB A602 2B23 61F1 C5D5 88EF`

## Build

Workflow her 6 saatte bir son release'i kontrol eder; yeni sürüm varsa
`animecix` paketini derler, imzalar ve GitHub Pages'e deploy eder.
Manuel tetikleme: Actions → **Arch paket repo** → Run workflow.
