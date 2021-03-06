# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit bash-completion-r1 udev

DESCRIPTION="A free and open TL866XX programmer"
HOMEPAGE="https://gitlab.com/DavidGriffith/minipro"
SRC_URI="https://gitlab.com/DavidGriffith/minipro/-/archive/${PV}/${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"

RESTRICT="mirror"

RDEPEND="virtual/libusb:1"
DEPEND="${RDEPEND}"

PREFIX="${EPREFIX}/usr"

src_compile() {
	# force minipro to use portage prefix
	emake PREFIX="${PREFIX}"
}

src_install() {
	dobin minipro miniprohex
	doman man/minipro.1

	# install device database
	insinto "${PREFIX}/share/minipro"
	doins infoic.xml

	udev_dorules udev/*.rules
	dobashcomp bash_completion.d/minipro
}
