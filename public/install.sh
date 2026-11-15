#!/usr/bin/env bash
# AnimeciX Arch Linux kurulum betiği.
# Kullanım:
#   curl -fsSL https://veilzon.github.io/animecix-arch/install.sh -o /tmp/animecix-install.sh
#   sudo bash /tmp/animecix-install.sh
# veya:
#   curl -fsSL https://veilzon.github.io/animecix-arch/install.sh | sudo bash
#
# Seçenekler:
#   -y, --yes   pacman sorularını otomatik onayla
#   -h, --help  bu yardımı göster

set -euo pipefail

REPO_URL="https://veilzon.github.io/animecix-arch"
KEY_ID="2B2361F1C5D588EF"
KEY_FPR="7A081AF63552C10A13BBA6022B2361F1C5D588EF"

info() { printf '==> %s\n' "$*"; }
die()  { printf 'HATA: %s\n' "$*" >&2; exit 1; }

usage() {
    cat <<'EOF'
AnimeciX Arch Linux kurulum betiği.

Kullanım:
  curl -fsSL https://veilzon.github.io/animecix-arch/install.sh -o /tmp/animecix-install.sh
  sudo bash /tmp/animecix-install.sh

veya:
  curl -fsSL https://veilzon.github.io/animecix-arch/install.sh | sudo bash

Seçenekler:
  -y, --yes   pacman sorularını otomatik onayla
  -h, --help  bu yardımı göster
EOF
}

ASSUME_YES=0
for arg in "$@"; do
    case "$arg" in
        -y|--yes) ASSUME_YES=1 ;;
        -h|--help) usage; exit 0 ;;
        *) die "Bilinmeyen argüman: $arg" ;;
    esac
done

[ -f /etc/arch-release ] || die "Bu betik Arch Linux içindir."
command -v curl >/dev/null 2>&1 || die "curl gerekli: sudo pacman -S curl"
command -v gpg  >/dev/null 2>&1 || die "gnupg gerekli: sudo pacman -S gnupg"

if [ "$(id -u)" -eq 0 ]; then
    as_root() { "$@"; }
else
    command -v sudo >/dev/null 2>&1 || die "sudo gerekli; betiği root olarak çalıştırın."
    as_root() { sudo "$@"; }
fi

PACFLAGS=()
[ "$ASSUME_YES" -eq 1 ] && PACFLAGS+=(--noconfirm)

KEY_FILE=$(mktemp)
trap 'rm -f "$KEY_FILE"' EXIT

info "AnimeciX imza anahtarı indiriliyor..."
curl -fsSL --location --show-error "$REPO_URL/animecix.gpg" -o "$KEY_FILE"

GOT_FPR=$(gpg --show-keys --with-colons "$KEY_FILE" 2>/dev/null \
    | awk -F: '/^fpr:/ {print $10; exit}')
[ "$GOT_FPR" = "$KEY_FPR" ] || die "Anahtar parmak izi beklenenden farklı: ${GOT_FPR:-okunamadı}"

info "Anahtar pacman keyring'e ekleniyor..."
as_root pacman-key --add "$KEY_FILE" >/dev/null
if [ "$ASSUME_YES" -eq 1 ]; then
    yes | as_root pacman-key --lsign-key "$KEY_ID" >/dev/null || true
else
    as_root pacman-key --lsign-key "$KEY_ID"
fi

if grep -q '^\[animecix\]' /etc/pacman.conf; then
    info "animecix deposu pacman.conf içinde zaten var."
else
    info "/etc/pacman.conf yedekleniyor ve depo ekleniyor..."
    as_root cp -a /etc/pacman.conf /etc/pacman.conf.animecix.bak
    as_root tee -a /etc/pacman.conf >/dev/null <<EOF

[animecix]
SigLevel = Required DatabaseOptional
Server = $REPO_URL/\$arch
EOF
fi

info "Sistem güncelleniyor ve AnimeciX kuruluyor..."
as_root pacman -Syu "${PACFLAGS[@]}"
as_root pacman -S --needed "${PACFLAGS[@]}" animecix

info "Kurulum tamam."
as_root pacman -Q animecix
info "AnimeciX'i menüden veya 'animecix' komutuyla açabilirsiniz."
