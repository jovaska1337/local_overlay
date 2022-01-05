EAPI=7

inherit ecm

if [ "${PV}" == 9999 ]; then
	EGIT_REPO_URI="https://github.com/psifidotos/applet-window-appmenu.git"
	inherit git-r3
else
	SRC_URI="https://github.com/psifidotos/applet-window-appmenu/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="~amd64 ~arm64"
fi

DESCRIPTION="Window appmenu widget for Plasma 5."
HOMEPAGE="https://github.com/psifidotos/applet-window-appmenu"

LICENSE="GPL-2+"
SLOT="5"
IUSE=""
RESTRICT="mirror"

# (these may be incomplete)
DEPEND="
	>=kde-frameworks/plasma-5.23.2:5
	>=kde-frameworks/kdeclarative-5.38
	>=kde-frameworks/kcoreaddons-5.38
	>=kde-frameworks/kirigami-5.38
	>=kde-frameworks/kwindowsystem-5.38
	>=kde-plasma/kdecoration-5.23:5
	x11-libs/libxcb
	x11-libs/libXrandr
"
RDEPEND="${DEPEND}"

#DOCS=( README.md )

src_unpack()
{
	default_src_unpack

	# fix directory name
	mv "${WORKDIR}/applet-window-appmenu-${PV}" "${WORKDIR}/${P}"
}
