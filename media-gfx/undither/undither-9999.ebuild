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
imgref-1.9.4
itertools-0.11.0
libc-0.2.144
lodepng-3.7.2
loop9-0.1.3
miniz_oxide-0.7.1
num-traits-0.2.15
rgb-0.8.36
vpsearch-2.0.1
fallible_collections-0.4.9
hashbrown-0.13.0
ahash-0.8.3
version_check-0.9.4
once_cell-1.18.0
"

inherit cargo git-r3

SRC_URI="$(cargo_crate_uris ${CRATES})"

# I'm not updating the crate list manually each time the developer decides
# to version bump dependencies, so this is it until some features are added
EGIT_COMMIT="0b1cb237949ed868ddbe8a3a77bbbee578b3a198"
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
