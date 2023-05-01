# Copyright 2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="A small module used to disable the client side decoration of GTK 3."
HOMEPAGE="https://github.com/PCMan/gtk3-nocsd"

inherit git-r3
EGIT_REPO_URI="https://github.com/PCMan/gtk3-nocsd"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~amd64 ~x86"

# should be okay
DEPEND="
	x11-libs/gtk+:3
	dev-libs/gobject-introspection
"
RDEPEND="${DEPEND}"
BDEPEND="${DEPEND}"

# no docs (who the hell wants these anyway)
DOCS=""
HTML_DOCS=""

src_prepare() {
	# remove hardcoded CFLAGS and modify install
	# prefix portage will automate the rest
	sed -i "/^prefix/c\\prefix ?= \"${EPREFIX}/usr\"" "${S}/Makefile" || die
	sed -i "/^libdir/s/\/lib/\/$(get_libdir)/g" "${S}/Makefile" || die
	sed -i "/^CFLAGS ?=/d" "${S}/Makefile" || die

	default_src_prepare
}

pkg_postinst() {
	# FIXME: write some automation magic for this later
	einfo "To disable GTK client side decorations,"
	einfo "put the following into your ~/.profile:"
	einfo " export GTK_CSD=0"
	einfo " export LD_PRELOAD=\"${EPREFIX}/usr/$(get_libdir)/libgtk3-nocsd.so.0\""

}
