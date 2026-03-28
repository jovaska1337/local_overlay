# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{10..13} pypy3 )

inherit distutils-r1 pypi

DESCRIPTION="Mozilla supplement library from Firefox source tree"

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

# disable tests
RESTRICT="test"

# FIXME: maybe incomplete
RDEPEND="
	dev-python/six
	dev-python/distro
"

# unpack firefox source and point $S to mozbase
src_unpack() {
	# regular unpack
	default_src_unpack

	# find firefox source dir
	local temp="$(find "$WORKDIR" -maxdepth 1 -mindepth 1 -type d)"

	# set source dir
	S="${temp}"
	[[ ! -d "$S" ]] && die

	# whitelisted modules
	local whitelist=(
		mozterm
		mozcrash
		#mozdebug
		mozdevice
		mozfile
		#mozgeckoprofiler
		#mozhttpd
		mozinfo
		mozinstall
		#mozleak
		mozlog
		moznetwork
		mozpower
		mozprocess
		mozprofile
		#mozproxy
		mozrunner
		#mozscreenshot
		#mozserve
		#mozsystemmonitor
		moztest
		mozversion
		wptserve
		manifestparser
		pywebsocket3
	)

	local added=()

	# get module names
	local path
	while read path; do
		local name="${path##*/}"

		# check if already added
		[[ " ${added[*]} " =~ " ${name} " ]] && continue

		# is this a python module?
		[[ -f "${path}/setup.py" ]] || continue

		# check if module is whitelisted
		local tmp
		for tmp in "${whitelist[@]}"; do
			if [[ "$tmp" == "$name" ]]; then
				# mozlog is in two places
				[[ "$name" == mozlog && "$path" == *third_party* ]] && continue
				einfo "Including module: ${name}"
				echo "$path" >> "${WORKDIR}/modules"
				break
			fi
		done
	done < <(find "${S}/python" "${S}/testing" -mindepth 1 -type d)
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
