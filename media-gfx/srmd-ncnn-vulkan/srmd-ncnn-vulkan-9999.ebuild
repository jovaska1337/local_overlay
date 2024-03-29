# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake

DESCRIPTION="SRMD super resolution implemented with ncnn library"
HOMEPAGE="https://github.com/nihui/srmd-ncnn-vulkan"

if [[ "$PV" == 9999 ]]; then
	inherit git-r3
	SRC_URI=""
	EGIT_REPO_URI="https://github.com/nihui/srmd-ncnn-vulkan"
	EGIT_SUBMODULES=()
else
	SRC_URI="
		https://github.com/nihui/${PN}/archive/refs/tags/${PV}.tar.gz-> ${P}.tar.gz"
fi

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"
RESTRICT="mirror"

RDEPEND="
	dev-libs/ncnn:=[vulkan]
	media-libs/libwebp:=
	media-libs/vulkan-loader"
DEPEND="
	${RDEPEND}
	dev-util/glslang
	dev-util/vulkan-headers"

src_prepare() {
	rm -rf "src/libwebp" "src/ncnn"

	CMAKE_USE_DIR="${S}/src"
	cmake_src_prepare

	# Update all paths to match installation for models.
	sed "s%PATHSTR(\"models\")%PATHSTR(\"${EPREFIX}/usr/share/${PN}/models\")%g" \
		-i src/main.cpp || die
}

src_configure() {
	local mycmakeargs=(
		-DGLSLANG_TARGET_DIR="${ESYSROOT}/usr/$(get_libdir)/cmake"
		-DUSE_SYSTEM_NCNN=ON
		-DUSE_SYSTEM_WEBP=ON
	)

	cmake_src_configure
}

src_install() {
	dobin "${BUILD_DIR}/srmd-ncnn-vulkan"

	insinto "/usr/share/${PN}/models"
	doins -r "${S}/models/models-srmd/."
}
