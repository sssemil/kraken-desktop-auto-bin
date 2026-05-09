#!/usr/bin/env bash
set -euo pipefail

PKGNAME="kraken-desktop-auto-bin"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PKGBUILD="${SCRIPT_DIR}/PKGBUILD"
SRCINFO="${SCRIPT_DIR}/.SRCINFO"
ICON="${SCRIPT_DIR}/kraken.png"
TMP_DIR="$(mktemp -d)"

cleanup() { rm -rf "$TMP_DIR"; }
trap cleanup EXIT

# ---------- helpers ----------

msg() { echo ":: $*"; }
die() { echo "ERROR: $*" >&2; exit 1; }

# ---------- read current version ----------

current_ver=$(grep -oP '^pkgver=\K.*' "$PKGBUILD")
msg "Current version in PKGBUILD: ${current_ver}"

# ---------- detect latest version ----------

ARCHS=(
  "x86_64:kraken-x86_64-unknown-linux-gnu.zip"
  "aarch64:kraken-aarch64-unknown-linux-gnu.zip"
  "armv7:kraken-armv7-unknown-linux-gnueabihf.zip"
)

BASE_URL="https://desktop-downloads.kraken.com/latest"
download_url() {
  local slug="$1"
  echo "${BASE_URL}/${slug}"
}

msg "Downloading x86_64 binary to detect latest version..."
x86_64_slug="kraken-x86_64-unknown-linux-gnu.zip"
curl -fsSL -o "${TMP_DIR}/${x86_64_slug}" "$(download_url "$x86_64_slug")"

latest_ver=$(unzip -p "${TMP_DIR}/${x86_64_slug}" kraken_desktop 2>/dev/null \
  | strings \
  | grep -oP '##\s+\K[0-9]+\.[0-9]+\.[0-9]+' \
  | sort -V \
  | tail -1)

if [[ -z "$latest_ver" ]]; then
  die "Could not detect latest version from binary. The changelog format may have changed."
fi

msg "Latest available version: ${latest_ver}"

if [[ "$latest_ver" == "$current_ver" ]]; then
  msg "Already up to date. Nothing to do."
  exit 0
fi

# ---------- new version: download all arch zips and compute sha256 ----------

msg "New version ${latest_ver} detected. Downloading all architectures..."

declare -A sha_sums

for entry in "${ARCHS[@]}"; do
  arch="${entry%%:*}"
  slug="${entry##*:}"
  local_name="${PKGNAME}-${latest_ver}-${arch}.zip"
  msg "  Downloading ${arch}..."
  curl -fsSL -o "${TMP_DIR}/${local_name}" "$(download_url "$slug")"
  sha_sums[$arch]=$(sha256sum "${TMP_DIR}/${local_name}" | cut -d' ' -f1)
  msg "    sha256: ${sha_sums[$arch]}"
done

msg "Computing sha256 for icon..."
sha_icon=$(sha256sum "$ICON" | cut -d' ' -f1)

# ---------- update PKGBUILD ----------

msg "Updating PKGBUILD..."

sed -i "s/^pkgver=.*/pkgver=${latest_ver}/"  "$PKGBUILD"
sed -i "s/^pkgrel=.*/pkgrel=1/"              "$PKGBUILD"
sed -i "s/^sha256sums=.*/sha256sums=('${sha_icon}')/"                "$PKGBUILD"
sed -i "s/^sha256sums_x86_64=.*/sha256sums_x86_64=('${sha_sums[x86_64]}')/"   "$PKGBUILD"
sed -i "s/^sha256sums_aarch64=.*/sha256sums_aarch64=('${sha_sums[aarch64]}')/" "$PKGBUILD"
sed -i "s/^sha256sums_armv7=.*/sha256sums_armv7=('${sha_sums[armv7]}')/"     "$PKGBUILD"

# ---------- generate .SRCINFO ----------

msg "Generating .SRCINFO..."

cat > "$SRCINFO" << SRCINFO_EOF
pkgbase = kraken-desktop-auto-bin
	pkgdesc = Kraken crypto exchange desktop application
	pkgver = ${latest_ver}
	pkgrel = 1
	url = https://www.kraken.com/desktop
	arch = aarch64
	arch = armv7
	arch = x86_64
	license = custom: commercial
	provides = kraken_desktop
	conflicts = kraken_desktop
	options = !debug
	options = !lto
	options = !strip
	source = kraken.png
	sha256sums = ${sha_icon}
	source_aarch64 = kraken-desktop-auto-bin-${latest_ver}-aarch64.zip::https://desktop-downloads.kraken.com/latest/kraken-aarch64-unknown-linux-gnu.zip
	sha256sums_aarch64 = ${sha_sums[aarch64]}
	source_armv7 = kraken-desktop-auto-bin-${latest_ver}-armv7.zip::https://desktop-downloads.kraken.com/latest/kraken-armv7-unknown-linux-gnueabihf.zip
	sha256sums_armv7 = ${sha_sums[armv7]}
	source_x86_64 = kraken-desktop-auto-bin-${latest_ver}-x86_64.zip::https://desktop-downloads.kraken.com/latest/kraken-x86_64-unknown-linux-gnu.zip
	sha256sums_x86_64 = ${sha_sums[x86_64]}

pkgname = kraken-desktop-auto-bin
SRCINFO_EOF

msg ""
msg "Update complete!"
msg "  Old version: ${current_ver}"
msg "  New version: ${latest_ver}"
msg ""
msg "Updated files: PKGBUILD, .SRCINFO"
msg "Review changes and commit to publish."
