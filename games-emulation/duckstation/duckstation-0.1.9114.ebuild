# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit xdg cmake desktop

DESCRIPTION="Fast Sony PlayStation (PSX) emulator"
HOMEPAGE="https://github.com/stenzek/duckstation"

if [[ "$PV" == 9999 ]]; then
	KEYWORDS=""
	EGIT_REPO_URI="https://github.com/stenzek/duckstation.git"
	SRC_URI=""
	inherit git-r3
else
	KEYWORDS="~amd64"
	REF="${PV##*.}"
	REF="${PV:0:$((${#PV} - ${#REF} - 1))}-${REF}"
	SRC_URI="https://github.com/stenzek/duckstation/archive/refs/tags/v${REF}.tar.gz -> ${PF}.tar.gz"
	S="${WORKDIR}/${PN}-${REF}"
fi

LICENSE="CC-BY-NC-ND-4.0"
SLOT="0"
IUSE="+qt6 +mini wayland X +vulkan"

RESTRICT="mirror"
PATCHES=(
	"${FILESDIR}/remove-discord.patch"
	"${FILESDIR}/pkg-config.patch"
	"${FILESDIR}/fix-soundtouch.patch"
	"${FILESDIR}/fix-missing-includes.patch"
)

BDEPEND="
	virtual/pkgconfig
	wayland? ( kde-frameworks/extra-cmake-modules )
"
DEPEND="
	sys-apps/dbus
	>=media-libs/libsdl3-3.2.16
	>=media-libs/plutosvg-0.0.6
	app-arch/ztsd
	media-libs/libwebp
	sys-libs/zlib
	>=media-libs/libpng-1.6.40
	virtual/jpeg
	>=media-libs/freetype-2.13.2
	media-libs/libsoundtouch
	dev-libs/libzip
	dev-libs/libudev
	dev-libs/libbacktrace
	dev-libs/spirv-cross
	>=media-video/ffmpeg-7.0.0
	media-libs/shaderc
	net-misc/curl
	X? (
		x11-libs/libxcb
		x11-libs/libX11
		x11-libs/libXrandr
	)
	qt6? (
		dev-qt/qtbase:6[gui,network,widgets]
		dev-qt/qttools:6[linguist]
	)
"
RDEPEND="${DEPEND}"

src_configure() {
	local mycmakeargs=(
		-DCMAKE_INSTALL_PREFIX=/opt/duckstation
		-DALLOW_INSTALL=ON
		-DINSTALL_SELF_CONTAINED=OFF
		-DBUILD_QT_FRONTEND=$(usex qt6)
		-DBUILD_MINI_FRONTEND=$(usex mini)
		-DENABLE_VULKAN=$(usex vulkan)
		-DENABLE_OPENGL=ON
		-DENABLE_WAYLAND=$(usex wayland)
		-DENABLE_X11=$(usex X)
	)
	cmake_src_configure
}
