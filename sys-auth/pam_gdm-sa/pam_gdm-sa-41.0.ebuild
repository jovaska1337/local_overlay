# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit meson pam

DESCRIPTION="pam_gdm.so standalone build extracted from GDM."
HOMEPAGE="https://wiki.gnome.org/Projects/GDM"

# we can't use gnome.org.eclass for this as the package name isn't gdm
# this is equivalent to what it does internally
SRC_URI="mirror://gnome/sources/gdm/$(ver_cut 1)/gdm-${PV}.tar.xz"

LICENSE="GPL-2+"

SLOT="0"

KEYWORDS="amd64 x86"

COMMON_DEPEND="
	sys-apps/keyutils:=
	sys-libs/pam
"
RDEPEND="$COMMON_DEPEND"
DEPEND="$COMMON_DEPEND"
BDEPEND="
	virtual/pkgconfig
"

PATCHES=(
	"${FILESDIR}/standalone-build.patch"
)

src_unpack() {
	default_src_unpack

	# we're only insterested in the pam_gdm directory in the gdm tree
	mv "${WORKDIR}/gdm-${PV}/pam_gdm" "${WORKDIR}/${P}" || die
}

src_configure() {
	local emesonargs=(
		-Dpam-mod-dir=$(getpam_mod_dir)
	)

	meson_src_configure
}

pkg_postinst() {
	einfo "The GDM PAM module is installed but not enabled yet."
	einfo "To avoid conflicts with gnome-base/gdm pam_gdm.so it's called pam_gdm-sa.so."
	einfo "In order to enable it, you need to add the following to your config in /etc/pam.d/:"
	einfo "    auth optional pam_gdm-sa.so"
	einfo "If you want to automatically unlock gnome-keyring make sure the"
	einfo "above line appears before the inclusion of pam_gnome_keyring.so."
}
