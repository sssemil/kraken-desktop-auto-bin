# Maintainer: sssemil <sssemil at github dot com>
# Contributor: Ergus <spacibba at aol dot com>
pkgname=kraken-desktop-auto-bin
pkgver=1.24.0
pkgrel=1
pkgdesc="Kraken crypto exchange desktop application"
arch=('aarch64' 'armv7' 'x86_64')
url="https://www.kraken.com/desktop"
license=('custom: commercial')
provides=('kraken_desktop')
conflicts=('kraken_desktop')

source=('kraken.png')

source_x86_64=("${pkgname}-${pkgver}-x86_64.zip::https://desktop-downloads.kraken.com/latest/kraken-x86_64-unknown-linux-gnu.zip")
source_armv7=("${pkgname}-${pkgver}-armv7.zip::https://desktop-downloads.kraken.com/latest/kraken-armv7-unknown-linux-gnueabihf.zip")
source_aarch64=("${pkgname}-${pkgver}-aarch64.zip::https://desktop-downloads.kraken.com/latest/kraken-aarch64-unknown-linux-gnu.zip")
sha256sums=('6fc49c5128736ffa958ded6d12f3a1fa819bce5b563e768d479ca01a67517148')
sha256sums_aarch64=('59642895531279071ec037ee5c749d32aa2845654a565f094f11ccd28f5aee2f')
sha256sums_armv7=('72cf92ce3882f2b0c75385776fe96db0737a473c4679ddd0ed98a44c2615e4bf')
sha256sums_x86_64=('342258e69a461e763fa0a367ce2bd571a8faba9852bf9de521bf50bbd6099d80')


options=('!debug' '!lto' '!strip')

package() {

	install -d -m755 "${pkgdir}/usr/bin"
	install -d -m755 "${pkgdir}/usr/share/"{applications,icons}

	install -Dm0755 -t "$pkgdir/usr/bin/" "kraken_desktop"
	install -Dm0644 -t "$pkgdir/usr/share/applications/" "kraken.desktop"

	install -Dm0644 -t "$pkgdir/usr/share/icons/" "kraken.png"
}
