EAPI=8

DESCRIPTION="Allow commands to MobileSafari and UIWebViews on real and simulated iOS devices."
HOMEPAGE="https://github.com/google/ios-webkit-debug-proxy"

inherit autotools

if [ "$PV" == 9999 ]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/google/ios-webkit-debug-proxy.git"
	KEYWORDS=""
else
	SRC_URI="https://github.com/google/${PN}/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="~amd64 ~x86"
fi

LICENSE="BSD-Google"
SLOT="0"

DEPEND="
	app-pda/libimobiledevice
	app-pda/libusbmuxd
	app-pda/usbmuxd
	app-pda/libplist
"
RDEPEND="${DEPEND}"

PATCHES=(
	"${FILESDIR}/fix-includes.patch"
)

src_prepare() {
	default
	eautoreconf
}

src_compile() {
	emake
}
