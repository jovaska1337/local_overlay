EAPI=8

# I sure fucking loved testing these manually
CRATES="
adler-1.0.2
autocfg-1.1.0
bytemuck-1.13.1
cfg-if-1.0.0
crc32fast-1.3.2
either-1.8.1
flate2-1.0.26
imgref-1.7.1
itertools-0.10.0
libc-0.2.144
lodepng-3.2.2
loop9-0.1.3
miniz_oxide-0.7.1
num-traits-0.2.15
rgb-0.8.25
vpsearch-2.0.1
"

inherit cargo git-r3

SRC_URI="$(cargo_crate_uris ${CRATES})"
EGIT_REPO_URI="https://github.com/kornelski/undither"

DESCRIPTION="Smart filter to remove Floyd-Steinberg dithering from paletted images."
HOMEPAGE="https://github.com/kornelski/undither"
LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
RESTRICT="mirror"
IUSE=""

DEPEND="
	${RUST_DEPEND}
	${RDEPEND}
"

src_unpack() {
	# unpack git and cargo
	git-r3_src_unpack
	cargo_src_unpack
}

src_configure() {
	cargo_src_configure --features=binary
}
