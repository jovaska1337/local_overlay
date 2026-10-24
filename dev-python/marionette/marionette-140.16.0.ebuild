# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{10..13} pypy3 )

inherit distutils-r1 pypi

DESCRIPTION="Marionette library from Firefox source tree"

LICENSE="MPL-2.0"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~arm64 ~hppa ~ia64 ~loong ~m68k ~mips ~ppc ~ppc64 ~riscv ~s390 ~sparc ~x86 ~arm64-macos ~x64-macos"
IUSE=""

# from firefox.ebuild
MOZ_PV=${PV}esr
MOZ_PN=firefox
MOZ_P="${MOZ_PN}-${MOZ_PV}"
MOZ_PV_DISTFILES="${MOZ_PV}${MOZ_PV_SUFFIX}"
MOZ_P_DISTFILES="${MOZ_PN}-${MOZ_PV_DISTFILES}"
MOZ_SRC_BASE_URI="https://archive.mozilla.org/pub/${MOZ_PN}/releases/${MOZ_PV}"

# utilize same sources as firefox ebuilds to avoid re-download
SRC_URI="${MOZ_SRC_BASE_URI}/source/${MOZ_P}.source.tar.xz -> ${MOZ_P_DISTFILES}.source.tar.xz"

RDEPEND="
	dev-python/six
	~dev-python/mozbase-${PV}
"

RESTRICT="test"

# unpack firefox source and point $S to marionette
src_unpack() {
	# regular unpack
	default_src_unpack

	# find firefox source dir
	local temp="$(find "$WORKDIR" -maxdepth 1 -mindepth 1 -type d)"

	# mozbase is here
	S="${temp}/testing/marionette"
	[[ ! -d "$S" ]] && die

	# module names
	echo "${S}/client" >> "${WORKDIR}/modules"
	echo "${S}/harness" >> "${WORKDIR}/modules"
}

src_prepare() {
	local path
	while read path; do
		export BUILD_DIR="${WORKDIR}/build/${path##*/}"
		export S="$path"
		cd "$S"
		distutils-r1_src_prepare
	done < "${WORKDIR}/modules"
}

src_configure() {
	local path
	while read path; do
		export BUILD_DIR="${WORKDIR}/build/${path##*/}"
		export S="$path"
		cd "$S"
		distutils-r1_src_configure
	done < "${WORKDIR}/modules"
}

src_compile() {
	local path
	while read path; do
		export BUILD_DIR="${WORKDIR}/build/${path##*/}"
		export S="$path"
		cd "$S"
		distutils-r1_src_compile
	done < "${WORKDIR}/modules"
}

src_install() {
	local path
	while read path; do
		export BUILD_DIR="${WORKDIR}/build/${path##*/}"
		export S="$path"
		cd "$S"
		distutils-r1_src_install
	done < "${WORKDIR}/modules"
}
