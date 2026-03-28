# Copyright 2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake git-r3

DESCRIPTION="A library for performing reflection and disassembly on SPIR-V."
HOMEPAGE="https://github.com/KhronosGroup/SPIRV-Cross"
EGIT_REPO_URI="https://github.com/KhronosGroup/SPIRV-Cross"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS=""

DEPEND="
	dev-util/spirv-headers
	dev-util/spirv-tools
	dev-util/glslang
"
RDEPEND="${DEPEND}"
BDEPEND=""

REQUIRED_USE="?? ( shared static )"
IUSE="+shared static tools"

src_configure() {
	local mycmakeargs=(
		-DSPIRV_CROSS_STATIC=$(usex static)
		-DSPIRV_CROSS_SHARED=$(usex shared)
		-DSPIRV_CROSS_CLI=$(usex tools)
	)
	cmake_src_configure
}
