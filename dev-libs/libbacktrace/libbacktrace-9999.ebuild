# Copyright 2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit autotools git-r3

DESCRIPTION="A C library produce symbolic backtraces."
HOMEPAGE="https://github.com/ianlancetaylor/libbacktrace"
EGIT_REPO_URI="https://github.com/ianlancetaylor/libbacktrace"

LICENSE="" # I don't fucking know?
SLOT="0"
KEYWORDS=""

DEPEND="
	|| (
		sys-devel/gcc
		llvm-core/clang-runtime
	)
"
RDEPEND="${DEPEND}"
BDEPEND=""

src_install() {
	default_src_install
	# remove libtool archives
	find "${D}" -name '*.la' -exec rm {} \;
}
