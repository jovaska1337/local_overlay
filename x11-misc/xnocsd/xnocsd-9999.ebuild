# Copyright 2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Disable GTK 3/4 client side decorations"
HOMEPAGE="https://gitlab.com/sulincix/xnocsd"

inherit git-r3
EGIT_REPO_URI="https://gitlab.com/sulincix/xnocsd"

LICENSE="GPLv3"
SLOT="0"
KEYWORDS="~x86 ~amd64"

DEPEND="
	x11-libs/gtk:3
	x11-libs/xorg-server
"
RDEPEND="${DEPEND}"
BDEPEND=""

# no docs please :)
DOCS=()

pkg_install() {
	insinto "/usr/share/xnocsd"
	doins "${S}/gtk.css"
}

pkg_postinst() {
	einfo "Add /usr/share/xnocsd/gtk.css into your ~/.config/gtk{3,4} folders."
}
