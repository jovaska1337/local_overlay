EAPI=8

inherit ecm

if [ "${PV}" == 9999 ]; then
	EGIT_REPO_URI="https://github.com/luisbocanegra/plasma-panel-spacer-extended"
	inherit git-r3
else
	SRC_URI="https://github.com/luisbocanegra/plasma-panel-spacer-extended/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="~amd64 ~arm64"
fi

DESCRIPTION="Extended panel spacer applet for Plasma 6"
HOMEPAGE="https://github.com/luisbocanegra/plasma-panel-spacer-extended"

LICENSE="public-domain" # this isn't licensed so I don't know...
SLOT="5" # keep as 5 so both versions don't coexist!
IUSE=""
RESTRICT="mirror"

# (these may be incomplete)
DEPEND="
	kde-plasma/libplasma:6
	kde-frameworks/kcoreaddons:6
	kde-plasma/kdeplasma-addons:6
"
RDEPEND="${DEPEND}"

#DOCS=( README.md )

src_unpack()
{
	[[ "${PV}" == 9999 ]] && git-r3_src_unpack || default_src_unpack

	# fix directory name
	mv "${WORKDIR}/"* "${WORKDIR}/${P}"
}
