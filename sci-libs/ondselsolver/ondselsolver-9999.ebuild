# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake

DESCRIPTION="Assembly Constraints and Multibody Dynamics code"
HOMEPAGE="https://github.com/Ondsel-Development/OndselSolver/"

EGIT_REPO_URI="https://github.com/FreeCAD/OndselSolver"
inherit git-r3

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="amd64"

IUSE="test"
RESTRICT="!test? ( test )"

DEPEND="test? ( dev-cpp/gtest )"

src_configure() {
	local mycmakeargs=(
		-DONDSELSOLVER_BUILD_TESTS=$(usex test)
	)

	cmake_src_configure
}
