# Copyright 2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit perl-module linux-info

DESCRIPTION="Daemon for connecting Bluetooth devices with HSP and HFP profiles."
HOMEPAGE="https://github.com/pali/hsphfpd-prototype"

if [ "$PV" == 9999 ]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/pali/hsphfpd-prototype"
else
	SRC_URI=""
fi

LICENSE="public-domain" # no license in the repo
SLOT="0"
KEYWORDS="~amd64 ~x86"
RESTRICT="mirror"

IUSE="doc extra"

RDEPEND="
	dev-lang/perl
	dev-perl/Net-DBus
"

pkg_setup() {
	CONFIG_CHECK="DEBUG_FS"
	linux-info_pkg_setup
}

src_install() {
	use doc && dodoc hsphfpd.txt

	exeinto "${EPREFIX}/usr/bin"
	if use extra; then
		newexe audio_client.pl  hsphfp-audio_client
		newexe telephony_client.pl hsphfp-telephony_client
		newexe sco_features.pl hsphfp-sco_features
	fi
	newexe hsphfpd.pl hsphfpd

	insinto /etc/dbus-1/system.d
	doins org.hsphfpd.conf

	exeinto /etc/init.d
	newexe "${FILESDIR}/hsphfpd.rc" hsphfpd
}

pkg_postinst() {
	einfo "You can use hsphfpd manually or use the "
	einfo "OpenRC service unit in /etc/init.d"
}
