EAPI=8

inherit ecm

if [[ "${PV}" == 9999 ]]; then
	EGIT_REPO_URI="https://github.com/moodyhunter/applet-window-title6.git"
	inherit git-r3
else
	SRC_URI="https://github.com/moodyhunter/applet-window-title6/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="~amd64 ~arm64"
fi

DESCRIPTION="Window title widget for Plasma 6"
HOMEPAGE="https://github.com/moodyhunter/applet-window-title6"

LICENSE="GPL-2+"
SLOT="6"
IUSE=""
RESTRICT="mirror"

# (these may be incomplete)
DEPEND="
	>=kde-plasma/libplasma-5.38
	>=kde-frameworks/kcoreaddons-5.38
"
RDEPEND="${DEPEND}"

#DOCS=( README.md )

src_unpack()
{
	[[ "${PV}" == 9999 ]] && git-r3_src_unpack || default_src_unpack

	# allow installation using ECM
	name="$(ls "$WORKDIR" | head -n1)"
	mkdir "${S}/package"
	for name in metadata.json contents; do
		mv "${S}/${name}" "${S}/package" || die
	done
	cp "${FILESDIR}/CMakeLists.txt" "$S" || die
}
