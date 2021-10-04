EAPI=7

inherit cmake desktop xdg

QZDL_REPO="https://github.com/qbasicer/qzdl"

DESCRIPTION="An easy to use and flexible DOOM launcher"
HOMEPAGE="https://zdl.vectec.net"

if [ "${PV}" == "9999" ]; then
	inherit git-r3
	EGIT_REPO_URI="${QZDL_REPO}"
else
	SRC_URI="${QZDL_REPO}/archive/g${PV}.tar.gz -> ${P}.tar.gz"
fi

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="+desktop-entry"

DEPEND="
	dev-qt/qtgui:5
	dev-qt/qtwidgets:5
	>=dev-libs/inih-53"
BDEPEND="
	${DEPEND}
	virtual/pkgconfig"

RDEPEND="${DEPEND}"

PATCHES=(
	# this is now merged into master
	#"${FILESDIR}/enable_file_selection.patch"
	"${FILESDIR}/shared_inih_and_install_target.patch"
)

src_prepare() {
	cmake_src_prepare
}

src_configure() {
	cmake_src_configure
}

src_install() {
	if use desktop-entry; then
		# find and install all the png icons
		find "res" -name "zdl3-*.png" \
			| while read icon; do
			size=`basename "${icon}" \
					| sed -e 's/[^-]*-\([0-9]\+\).*/\1/g'`

			# allow valid sizes
			case "$size" in
				16|22|24|32|36|48|64|72|96|128|192|256|512);;
				*) continue;;
			esac

			newicon -s "${size}" "${icon}" "${PN}.png";
		done

		# install the svg icon
		newicon -s scalable "res/zdl3.svg" "${PN}.svg"

		# make a desktop entry
		make_desktop_entry "${PN}" "ZDL" "${PN}" "Game;"
	fi

	cmake_src_install
}

pkg_postinst() {
	xdg_pkg_postinst
}
