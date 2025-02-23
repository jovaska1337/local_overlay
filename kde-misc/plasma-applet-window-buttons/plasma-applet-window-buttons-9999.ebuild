EAPI=8

inherit ecm

if [ "${PV}" == 9999 ]; then
	EGIT_REPO_URI="https://github.com/moodyhunter/applet-window-buttons6.git"
	inherit git-r3
else
	SRC_URI="https://github.com/moodyhunter/applet-window-buttons6/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="~amd64 ~arm64"
fi

DESCRIPTION="Window buttons widget for Plasma 6"
HOMEPAGE="https://github.com/moodyhunter/applet-window-buttons6"

LICENSE="GPL-2+"
SLOT="6"
IUSE=""
RESTRICT="mirror"

# (these may be incomplete)
DEPEND="
	kde-plasma/libplasma:6
	kde-frameworks/kdeclarative:6
	kde-frameworks/kcoreaddons:6
	kde-plasma/kdecoration:6
"
RDEPEND="${DEPEND}"

#DOCS=( README.md )

#PATCHES=( "${FILESDIR}/kdecoration3.patch" )

src_unpack()
{
	[[ "${PV}" == 9999 ]] && git-r3_src_unpack || default_src_unpack

	# fix directory name
	mv "${WORKDIR}/"* "${WORKDIR}/${P}"
}
