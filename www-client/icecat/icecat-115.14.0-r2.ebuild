# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# makceiceat is integrated into this ebuild in src_prepare()
# based on firefox-115.14.0.ebuild

EAPI=8

# this commit should have version numbers that match this ebuild
# as the firefox source fetching is integrated here as well to
# utilize the portage distfiles cache
COMMIT="4bd4d4948f2db495872ee11a8a7b0dd30549656c"

# this comes from firefox-${PV}.ebuild
FIREFOX_PATCHSET="firefox-115esr-patches-13.tar.xz"

LLVM_MAX_SLOT=18

PYTHON_COMPAT=( python3_{10..11} )
PYTHON_REQ_USE="ncurses,sqlite,ssl"

WANT_AUTOCONF="2.1"

VIRTUALX_REQUIRED="manual"

inherit autotools check-reqs desktop flag-o-matic gnome2-utils linux-info llvm multiprocessing \
	optfeature pax-utils python-any-r1 readme.gentoo-r1 toolchain-funcs virtualx xdg

PATCH_URIS=(
	https://dev.gentoo.org/~juippis/mozilla/patchsets/${FIREFOX_PATCHSET}
)

# download firefox source using portage (makeicecat needs to be patched for this)
SRC_URI="
	https://archive.mozilla.org/pub/firefox/candidates/${PV}esr-candidates/build${PR:1}/source/firefox-${PV}esr.source.tar.xz -> firefox-${PV}-${PR:1}esr.source.tar.xz
	https://git.savannah.gnu.org/cgit/gnuzilla.git/snapshot/gnuzilla-${COMMIT}.tar.gz -> makeicecat-${PVR}.tar.gz
	${PATCH_URIS[@]}
"

DESCRIPTION="GNU IceCat Web Browser"
HOMEPAGE="https://www.gnu.org/software/gnuzilla/"

KEYWORDS="~amd64 ~x86"
RESTRICT="mirror network-sandbox" # makeicecat needs network access

SLOT="0/$(ver_cut 1)"
LICENSE="MPL-2.0 GPL-2 LGPL-2.1"

IUSE="+clang cpu_flags_arm_neon dbus debug hardened hwaccel"
IUSE+=" jack libproxy lto +openh264 pgo pulseaudio sndio selinux"
IUSE+=" +system-av1 +system-harfbuzz +system-icu +system-jpeg +system-libevent +system-libvpx +system-png system-python-libs +system-webp"
IUSE+=" wayland wifi +X"

# Firefox-only IUSE
IUSE+=" geckodriver screencast"
IUSE+=" unity-menubar custom-fixes userchrome-js kde"

REQUIRED_USE="|| ( X wayland )
	debug? ( !system-av1 )
	pgo? ( lto )
	wifi? ( dbus )"

# Firefox-only REQUIRED_USE flags
REQUIRED_USE+=" unity-menubar? ( dbus )"

# FIXME: I don't know what the KDE patches from OpenSUSE require
FF_ONLY_DEPEND="!www-client/icecat:0
	screencast? ( media-video/pipewire:= )
	selinux? ( sec-policy/selinux-mozilla )
	unity-menubar? ( dev-libs/libdbusmenu )"

BDEPEND="${PYTHON_DEPS}
	|| (
		(
			sys-devel/clang:18
			sys-devel/llvm:18
			clang? (
				sys-devel/lld:18
				virtual/rust:0/llvm-18
				pgo? ( =sys-libs/compiler-rt-sanitizers-18*[profile] )
			)
		)
		(
			sys-devel/clang:17
			sys-devel/llvm:17
			clang? (
				sys-devel/lld:17
				virtual/rust:0/llvm-17
				pgo? ( =sys-libs/compiler-rt-sanitizers-17*[profile] )
			)
		)
		(
			sys-devel/clang:16
			sys-devel/llvm:16
			clang? (
				sys-devel/lld:16
				virtual/rust:0/llvm-16
				pgo? ( =sys-libs/compiler-rt-sanitizers-16*[profile] )
			)
		)
		(
			sys-devel/clang:15
			sys-devel/llvm:15
			clang? (
				sys-devel/lld:15
				virtual/rust:0/llvm-15
				pgo? ( =sys-libs/compiler-rt-sanitizers-15*[profile] )
			)
		)
	)
	app-alternatives/awk
	app-arch/unzip
	app-arch/zip
	>=dev-util/cbindgen-0.24.3
	net-libs/nodejs
	virtual/pkgconfig
	!clang? ( virtual/rust )
	!elibc_glibc? (
		|| (
			dev-lang/rust
			<dev-lang/rust-bin-1.73
		)
	)
	amd64? ( >=dev-lang/nasm-2.14 )
	x86? ( >=dev-lang/nasm-2.14 )
	pgo? (
		X? (
			sys-devel/gettext
			x11-base/xorg-server[xvfb]
			x11-apps/xhost
		)
		!X? (
			|| (
				gui-wm/tinywl
				<gui-libs/wlroots-0.17.3[tinywl(-)]
			)
			x11-misc/xkeyboard-config
		)
	)"
COMMON_DEPEND="${FF_ONLY_DEPEND}
	>=app-accessibility/at-spi2-core-2.46.0:2
	dev-libs/expat
	dev-libs/glib:2
	dev-libs/libffi:=
	>=dev-libs/nss-3.90
	>=dev-libs/nspr-4.35
	media-libs/alsa-lib
	media-libs/fontconfig
	media-libs/freetype
	media-libs/mesa
	media-video/ffmpeg
	sys-libs/zlib
	virtual/freedesktop-icon-theme
	x11-libs/cairo
	x11-libs/gdk-pixbuf
	x11-libs/pango
	x11-libs/pixman
	dbus? (
		dev-libs/dbus-glib
		sys-apps/dbus
	)
	jack? ( virtual/jack )
	pulseaudio? (
		|| (
			media-libs/libpulse
			>=media-sound/apulse-0.1.12-r4[sdk]
		)
	)
	libproxy? ( net-libs/libproxy )
	selinux? ( sec-policy/selinux-mozilla )
	sndio? ( >=media-sound/sndio-1.8.0-r1 )
	screencast? ( media-video/pipewire:= )
	system-av1? (
		>=media-libs/dav1d-1.0.0:=
		>=media-libs/libaom-1.0.0:=
	)
	system-harfbuzz? (
		>=media-gfx/graphite2-1.3.13
		>=media-libs/harfbuzz-2.8.1:0=
	)
	system-icu? ( >=dev-libs/icu-73.1:= )
	system-jpeg? ( >=media-libs/libjpeg-turbo-1.2.1 )
	system-libevent? ( >=dev-libs/libevent-2.1.12:0=[threads(+)] )
	system-libvpx? ( >=media-libs/libvpx-1.8.2:0=[postproc] )
	system-png? ( >=media-libs/libpng-1.6.35:0=[apng] )
	system-webp? ( >=media-libs/libwebp-1.1.0:0= )
	wayland? (
		>=media-libs/libepoxy-1.5.10-r1
		x11-libs/gtk+:3[wayland]
		x11-libs/libxkbcommon[wayland]
	)
	wifi? (
		kernel_linux? (
			dev-libs/dbus-glib
			net-misc/networkmanager
			sys-apps/dbus
		)
	)
	X? (
		virtual/opengl
		x11-libs/cairo[X]
		x11-libs/gtk+:3[X]
		x11-libs/libX11
		x11-libs/libXcomposite
		x11-libs/libXdamage
		x11-libs/libXext
		x11-libs/libXfixes
		x11-libs/libxkbcommon[X]
		x11-libs/libXrandr
		x11-libs/libXtst
		x11-libs/libxcb:=
	)"

RDEPEND="${COMMON_DEPEND}
	hwaccel? (
		media-video/libva-utils
		sys-apps/pciutils
	)
	jack? ( virtual/jack )
	openh264? ( media-libs/openh264:*[plugin] )"

DEPEND="${COMMON_DEPEND}
	X? (
		x11-base/xorg-proto
		x11-libs/libICE
		x11-libs/libSM
	)"

S="${WORKDIR}/${PN}-${PV%_*}"

llvm_check_deps() {
	if ! has_version -b "sys-devel/clang:${LLVM_SLOT}" ; then
		einfo "sys-devel/clang:${LLVM_SLOT} is missing! Cannot use LLVM slot ${LLVM_SLOT} ..." >&2
		return 1
	fi

	if use clang && ! tc-ld-is-mold ; then
		if ! has_version -b "sys-devel/lld:${LLVM_SLOT}" ; then
			einfo "sys-devel/lld:${LLVM_SLOT} is missing! Cannot use LLVM slot ${LLVM_SLOT} ..." >&2
			return 1
		fi

		if ! has_version -b "virtual/rust:0/llvm-${LLVM_SLOT}" ; then
			einfo "virtual/rust:0/llvm-${LLVM_SLOT} is missing! Cannot use LLVM slot ${LLVM_SLOT} ..." >&2
			return 1
		fi

		if use pgo ; then
			if ! has_version -b "=sys-libs/compiler-rt-sanitizers-${LLVM_SLOT}*[profile]" ; then
				einfo "=sys-libs/compiler-rt-sanitizers-${LLVM_SLOT}*[profile] is missing!"
				einfo "Cannot use LLVM slot ${LLVM_SLOT} ..." >&2
				return 1
			fi
		fi
	fi

	einfo "Using LLVM slot ${LLVM_SLOT} to build" >&2
}

MOZ_LANGS=(
	af ar ast be bg br ca cak cs cy da de dsb
	el en-CA en-GB en-US es-AR es-ES et eu
	fi fr fy-NL ga-IE gd gl he hr hsb hu
	id is it ja ka kab kk ko lt lv ms nb-NO nl nn-NO
	pa-IN pl pt-BR pt-PT rm ro ru
	sk sl sq sr sv-SE th tr uk uz vi zh-CN zh-TW
)

# Firefox-only LANGS
MOZ_LANGS+=( ach )
MOZ_LANGS+=( an )
MOZ_LANGS+=( az )
MOZ_LANGS+=( bn )
MOZ_LANGS+=( bs )
MOZ_LANGS+=( ca-valencia )
MOZ_LANGS+=( eo )
MOZ_LANGS+=( es-CL )
MOZ_LANGS+=( es-MX )
MOZ_LANGS+=( fa )
MOZ_LANGS+=( ff )
MOZ_LANGS+=( fur )
MOZ_LANGS+=( gn )
MOZ_LANGS+=( gu-IN )
MOZ_LANGS+=( hi-IN )
MOZ_LANGS+=( hy-AM )
MOZ_LANGS+=( ia )
MOZ_LANGS+=( km )
MOZ_LANGS+=( kn )
MOZ_LANGS+=( lij )
MOZ_LANGS+=( mk )
MOZ_LANGS+=( mr )
MOZ_LANGS+=( my )
MOZ_LANGS+=( ne-NP )
MOZ_LANGS+=( oc )
MOZ_LANGS+=( sc )
MOZ_LANGS+=( sco )
MOZ_LANGS+=( si )
MOZ_LANGS+=( son )
MOZ_LANGS+=( szl )
MOZ_LANGS+=( ta )
MOZ_LANGS+=( te )
MOZ_LANGS+=( tl )
MOZ_LANGS+=( trs )
MOZ_LANGS+=( ur )
MOZ_LANGS+=( xh )

mozilla_set_globals() {
	# https://bugs.gentoo.org/587334
	local MOZ_TOO_REGIONALIZED_FOR_L10N=(
		fy-NL ga-IE gu-IN hi-IN hy-AM nb-NO ne-NP nn-NO pa-IN sv-SE
	)

	local lang xflag
	for lang in "${MOZ_LANGS[@]}" ; do
		# en and en_US are handled internally
		if [[ ${lang} == en ]] || [[ ${lang} == en-US ]] ; then
			continue
		fi

		# strip region subtag if $lang is in the list
		if has ${lang} "${MOZ_TOO_REGIONALIZED_FOR_L10N[@]}" ; then
			xflag=${lang%%-*}
		else
			xflag=${lang}
		fi

		# makeicecat uses these to select included locales
		# l10n is broken ATM, needs fixing :)
		IUSE+=" l10n_${xflag/[_@]/-}"
	done
}
mozilla_set_globals

moz_clear_vendor_checksums() {
	debug-print-function ${FUNCNAME} "$@"

	if [[ ${#} -ne 1 ]] ; then
		die "${FUNCNAME} requires exact one argument"
	fi

	einfo "Clearing cargo checksums for ${1} ..."

	sed -i \
		-e 's/\("files":{\)[^}]*/\1/' \
		"${S}"/third_party/rust/${1}/.cargo-checksum.json \
		|| die
}

moz_install_xpi() {
	debug-print-function ${FUNCNAME} "$@"

	if [[ ${#} -lt 2 ]] ; then
		die "${FUNCNAME} requires at least two arguments"
	fi

	local DESTDIR=${1}
	shift

	insinto "${DESTDIR}"

	local emid xpi_file xpi_tmp_dir
	for xpi_file in "${@}" ; do
		emid=
		xpi_tmp_dir=$(mktemp -d --tmpdir="${T}")

		# Unpack XPI
		unzip -qq "${xpi_file}" -d "${xpi_tmp_dir}" || die

		# Determine extension ID
		if [[ -f "${xpi_tmp_dir}/install.rdf" ]] ; then
			emid=$(sed -n -e '/install-manifest/,$ { /em:id/!d; s/.*[\">]\([^\"<>]*\)[\"<].*/\1/; p; q }' "${xpi_tmp_dir}/install.rdf")
			[[ -z "${emid}" ]] && die "failed to determine extension id from install.rdf"
		elif [[ -f "${xpi_tmp_dir}/manifest.json" ]] ; then
			emid=$(sed -n -e 's/.*"id": "\([^"]*\)".*/\1/p' "${xpi_tmp_dir}/manifest.json")
			[[ -z "${emid}" ]] && die "failed to determine extension id from manifest.json"
		else
			die "failed to determine extension id"
		fi

		einfo "Installing ${emid}.xpi into ${ED}${DESTDIR} ..."
		newins "${xpi_file}" "${emid}.xpi"
	done
}

mozconfig_add_options_ac() {
	debug-print-function ${FUNCNAME} "$@"

	if [[ ${#} -lt 2 ]] ; then
		die "${FUNCNAME} requires at least two arguments"
	fi

	local reason=${1}
	shift

	local option
	for option in ${@} ; do
		echo "ac_add_options ${option} # ${reason}" >>${MOZCONFIG}
	done
}

mozconfig_add_options_mk() {
	debug-print-function ${FUNCNAME} "$@"

	if [[ ${#} -lt 2 ]] ; then
		die "${FUNCNAME} requires at least two arguments"
	fi

	local reason=${1}
	shift

	local option
	for option in ${@} ; do
		echo "mk_add_options ${option} # ${reason}" >>${MOZCONFIG}
	done
}

mozconfig_use_enable() {
	debug-print-function ${FUNCNAME} "$@"

	if [[ ${#} -lt 1 ]] ; then
		die "${FUNCNAME} requires at least one arguments"
	fi

	local flag=$(use_enable "${@}")
	mozconfig_add_options_ac "$(use ${1} && echo +${1} || echo -${1})" "${flag}"
}

mozconfig_use_with() {
	debug-print-function ${FUNCNAME} "$@"

	if [[ ${#} -lt 1 ]] ; then
		die "${FUNCNAME} requires at least one arguments"
	fi

	local flag=$(use_with "${@}")
	mozconfig_add_options_ac "$(use ${1} && echo +${1} || echo -${1})" "${flag}"
}

# This is a straight copypaste from toolchain-funcs.eclass's 'tc-ld-is-lld', and is temporarily
# placed here until toolchain-funcs.eclass gets an official support for mold linker.
# Please see:
# https://github.com/gentoo/gentoo/pull/28366 ||
# https://github.com/gentoo/gentoo/pull/28355
tc-ld-is-mold() {
	local out

	# Ensure ld output is in English.
	local -x LC_ALL=C

	# First check the linker directly.
	out=$($(tc-getLD "$@") --version 2>&1)
	if [[ ${out} == *"mold"* ]] ; then
		return 0
	fi

	# Then see if they're selecting mold via compiler flags.
	# Note: We're assuming they're using LDFLAGS to hold the
	# options and not CFLAGS/CXXFLAGS.
	local base="${T}/test-tc-linker"
	cat <<-EOF > "${base}.c"
	int main() { return 0; }
	EOF
	out=$($(tc-getCC "$@") ${CFLAGS} ${CPPFLAGS} ${LDFLAGS} -Wl,--version "${base}.c" -o "${base}" 2>&1)
	rm -f "${base}"*
	if [[ ${out} == *"mold"* ]] ; then
		return 0
	fi

	# No mold here!
	return 1
}

virtwl() {
	debug-print-function ${FUNCNAME} "$@"

	[[ $# -lt 1 ]] && die "${FUNCNAME} needs at least one argument"
	[[ -n $XDG_RUNTIME_DIR ]] || die "${FUNCNAME} needs XDG_RUNTIME_DIR to be set; try xdg_environment_reset"
	tinywl -h >/dev/null || die 'tinywl -h failed'

	# TODO: don't run addpredict in utility function. WLR_RENDERER=pixman doesn't work
	addpredict /dev/dri
	local VIRTWL VIRTWL_PID
	coproc VIRTWL { WLR_BACKENDS=headless exec tinywl -s 'echo $WAYLAND_DISPLAY; read _; kill $PPID'; }
	local -x WAYLAND_DISPLAY
	read WAYLAND_DISPLAY <&${VIRTWL[0]}

	debug-print "${FUNCNAME}: $@"
	"$@"
	local r=$?

	[[ -n $VIRTWL_PID ]] || die "tinywl exited unexpectedly"
	exec {VIRTWL[0]}<&- {VIRTWL[1]}>&-
	return $r
}

pkg_pretend() {
	if use pgo ; then
		if ! has usersandbox $FEATURES ; then
			die "You must enable usersandbox as X server can not run as root!"
		fi
	fi

	# Ensure we have enough disk space to compile
	if use pgo || use lto || use debug ; then
		CHECKREQS_DISK_BUILD="13500M"
	else
		CHECKREQS_DISK_BUILD="6600M"
	fi

	check-reqs_pkg_pretend
}

pkg_setup() {
	if use pgo ; then
		if ! has userpriv ${FEATURES} ; then
			eerror "Building ${PN} with USE=pgo and FEATURES=-userpriv is not supported!"
		fi
	fi

	# Ensure we have enough disk space to compile
	if use pgo || use lto || use debug ; then
		CHECKREQS_DISK_BUILD="13500M"
	else
		CHECKREQS_DISK_BUILD="6400M"
	fi

	check-reqs_pkg_setup

	llvm_pkg_setup

	if use clang && use lto && tc-ld-is-lld ; then
		local version_lld=$(ld.lld --version 2>/dev/null | awk '{ print $2 }')
		[[ -n ${version_lld} ]] && version_lld=$(ver_cut 1 "${version_lld}")
		[[ -z ${version_lld} ]] && die "Failed to read ld.lld version!"

		local version_llvm_rust=$(rustc -Vv 2>/dev/null | grep -F -- 'LLVM version:' | awk '{ print $3 }')
		[[ -n ${version_llvm_rust} ]] && version_llvm_rust=$(ver_cut 1 "${version_llvm_rust}")
		[[ -z ${version_llvm_rust} ]] && die "Failed to read used LLVM version from rustc!"

		if ver_test "${version_lld}" -ne "${version_llvm_rust}" ; then
			eerror "Rust is using LLVM version ${version_llvm_rust} but ld.lld version belongs to LLVM version ${version_lld}."
			eerror "You will be unable to link ${CATEGORY}/${PN}. To proceed you have the following options:"
			eerror "  - Manually switch rust version using 'eselect rust' to match used LLVM version"
			eerror "  - Switch to dev-lang/rust[system-llvm] which will guarantee matching version"
			eerror "  - Build ${CATEGORY}/${PN} without USE=lto"
			eerror "  - Rebuild lld with llvm that was used to build rust (may need to rebuild the whole "
			eerror "    llvm/clang/lld/rust chain depending on your @world updates)"
			die "LLVM version used by Rust (${version_llvm_rust}) does not match with ld.lld version (${version_lld})!"
		fi
	fi

	python-any-r1_pkg_setup

	# Avoid PGO profiling problems due to enviroment leakage
	# These should *always* be cleaned up anyway
	unset \
		DBUS_SESSION_BUS_ADDRESS \
		DISPLAY \
		ORBIT_SOCKETDIR \
		SESSION_MANAGER \
		XAUTHORITY \
		XDG_CACHE_HOME \
		XDG_SESSION_COOKIE

	# Build system is using /proc/self/oom_score_adj, bug #604394
	addpredict /proc/self/oom_score_adj

	if use pgo ; then
		# Update 105.0: "/proc/self/oom_score_adj" isn't enough anymore with pgo, but not sure
		# whether that's due to better OOM handling by Firefox (bmo#1771712), or portage
		# (PORTAGE_SCHEDULING_POLICY) update...
		addpredict /proc

		# May need a wider addpredict when using wayland+pgo.
		addpredict /dev/dri
	fi

	if ! mountpoint -q /dev/shm ; then
		# If /dev/shm is not available, configure is known to fail with
		# a traceback report referencing /usr/lib/pythonN.N/multiprocessing/synchronize.py
		ewarn "/dev/shm is not mounted -- expect build failures!"
	fi

	# Ensure we use C locale when building, bug #746215
	export LC_ALL=C

	# probably unnecessary because we're not compiling with DRM support...
	#CONFIG_CHECK="~SECCOMP"
	#WARNING_SECCOMP="CONFIG_SECCOMP not set! This system will be unable to play DRM-protected content."
	#linux-info_pkg_setup
}

src_unpack() {
	# unpack sources
	default_src_unpack

	# set source directory to makeicecat sources
	ln -s "${WORKDIR}/gnuzilla-${COMMIT}" "$S"
}

_makeicecat() {
	# disable unnecessary makeicecat phases
	local disable=( fetch_source verify_sources extract_sources finalize_sourceball )
	local phase
	for phase in "${disable[@]}"; do
		sed "s/^\\s*${phase}\\s*$/#${phase}/g" -i "${S}/makeicecat" || die
	done

	# add custom code after prepare_env
	sed "s/^\\s*prepare_env\\s*$/prepare_env \&\& source after_env.sh || exit 1/g" -i "${S}/makeicecat" || die

	# run the following after prepare_env in makeicecat
	echo "#!/bin/bash" > after_env.sh && chmod +x after_env.sh || die

	# this is normally done by fetch_source
	echo "cd output" >> after_env.sh

	# use already unpacked firefox sources via symlink
	echo "ln -s '${S}/../firefox-${PV}' 'icecat-${PV}'" >> after_env.sh

	# add selected locales to build
	echo -n > "${WORKDIR}/firefox-${PV}/browser/locales/shipped-locales" || die
	local flag has_l10n=0
	for flag in $IUSE; do
		# strip possible +
		flag="${flag##+}"

		# not lang flag
		[[ "$flag" != l10n_* ]] && continue

		# not using this flag
		use "$flag" || continue

		# strip l10n
		flag="${flag##l10n_}"

		# add locale
		einfo "Adding locale ${flag}"
		echo "$flag" >> "${WORKDIR}/firefox-${PV}/browser/locales/shipped-locales"

		has_l10n=1
	done

	# append files conditionally (ie. if target langpack exists)
	eapply "${FILESDIR}/patches/makeicecat-cond-append.patch"

	# no locales, need to patch
	if [[ "$has_l10n" != 1 ]]; then
		eapply "${FILESDIR}/patches/makeicecat-no-l10n.patch"
	fi

	# run makeicecat
	einfo "Running makeicecat ..."
	./makeicecat || die
}

src_prepare() {
	# temporarily switch to unpacked firefox sources
	export S="${WORKDIR}/firefox-${PV}" && cd "$S" || die

	if use lto; then
		rm -v "${WORKDIR}"/firefox-patches/*-LTO-Only-enable-LTO-*.patch || die
	fi

	if use x86 && use elibc_glibc ; then
		rm -v "${WORKDIR}"/firefox-patches/*-musl-non-lfs64-api-on-audio_thread_priority-crate.patch || die
	fi

	# Workaround for bgo#917599
	if has_version ">=dev-libs/icu-74.1" && use system-icu ; then
		eapply "${WORKDIR}"/firefox-patches/0029-bmo-1862601-system-icu-74.patch
	fi
	rm -v "${WORKDIR}"/firefox-patches/0029-bmo-1862601-system-icu-74.patch || die

	# Workaround for bgo#915651 on musl
	if use elibc_glibc ; then
		rm -v "${WORKDIR}"/firefox-patches/*bgo-748849-RUST_TARGET_override.patch || die
	fi

	eapply "${WORKDIR}/firefox-patches"

	# apply the unity-menubar patch if useflag is enabled
	if use unity-menubar; then
		eapply "${FILESDIR}/patches/$(ver_cut 1)-unity-menubar.patch"
		#eapply "${FILESDIR}/patches/show-window-buttons.patch"
	fi

	# KDE integration from OpenSUSE
	if use kde; then
		eapply "${FILESDIR}/patches/$(ver_cut 1)-kde-toolkit.patch"
		eapply "${FILESDIR}/patches/$(ver_cut 1)-kde-browser.patch"
	fi

	# switch back to gnuzilla sources
	export S="${WORKDIR}/icecat-${PV}" && cd "$S" || die

	# run makeicecat after patches have been applied to avoid conflicts
	_makeicecat

	# switch source to generated icecat sources
	export S="${WORKDIR}/firefox-${PV}" && cd "$S" || die

	# apply custom fixes if useflag is enabled
	if use custom-fixes; then
		local ts=$(date +%s)
		
		# custom default search engines
		rm -rf "${S}/browser/components/search/extensions/"* || die
		cp -R "${FILESDIR}/search/engines/"* \
			"${S}/browser/components/search/extensions" || die
		sed "s/@TS@/${ts}/g" "${FILESDIR}/search/engines.json" \
			> "${S}/services/settings/dumps/main/search-config.json" || die
		sed "s/@TS@/${ts}/g" "${FILESDIR}/search/empty.json" \
			> "${S}/services/settings/dumps/main/search-telemetry-v2.json" || die
		sed "s/@TS@/${ts}/g" "${FILESDIR}/search/empty.json" \
			> "${S}/services/settings/dumps/main/search-default-override-allowlist.json" || die

		# remove default top sites
		sed "s/@TS@/${ts}/g" "${FILESDIR}/search/empty.json" \
			> "${S}/services/settings/dumps/main/top-sites.json" || die

		# remove default extensions
		sed -i '/@BINPATH@\/extensions/d' \
			 "${S}/mobile/android/installer/package-manifest.in" || die
		sed -i '/@BINPATH@\/browser\/extensions/d' \
			"${S}/browser/installer/package-manifest.in" || die
		eapply "${FILESDIR}/patches/disable-extensions.patch"

		# OpenSUSE gconf proxy fix
		#eapply "${FILESDIR}/patches/$(ver_cut 1)-gconf-proxy.patch"
	fi

	# Allow user to apply any additional patches without modifing ebuild
	# NOTE: user patches apply to modified sources modified by makeicecat!
	eapply_user

	# Make cargo respect MAKEOPTS
	export CARGO_BUILD_JOBS="$(makeopts_jobs)"

	# Workaround for bgo#915651
	if ! use elibc_glibc ; then
		if use amd64 ; then
			export RUST_TARGET="x86_64-unknown-linux-musl"
		elif use x86 ; then
			export RUST_TARGET="i686-unknown-linux-musl"
		elif use arm64 ; then
			export RUST_TARGET="aarch64-unknown-linux-musl"
		else
			die "Unknown musl chost, please post your rustc -vV along with emerge --info on Gentoo's bug #915651"
		fi
	fi

	# Make LTO respect MAKEOPTS
	sed -i \
		-e "s/multiprocessing.cpu_count()/$(makeopts_jobs)/" \
		"${S}"/build/moz.configure/lto-pgo.configure \
		|| die "sed failed to set num_cores"

	# Make ICU respect MAKEOPTS
	sed -i \
		-e "s/multiprocessing.cpu_count()/$(makeopts_jobs)/" \
		"${S}"/intl/icu_sources_data.py \
		|| die "sed failed to set num_cores"

	# sed-in toolchain prefix
	sed -i \
		-e "s/objdump/${CHOST}-objdump/" \
		"${S}"/python/mozbuild/mozbuild/configure/check_debug_ranges.py \
		|| die "sed failed to set toolchain prefix"

	sed -i \
		-e 's/ccache_stats = None/return None/' \
		"${S}"/python/mozbuild/mozbuild/controller/building.py \
		|| die "sed failed to disable ccache stats call"

	einfo "Removing pre-built binaries ..."

	find "${S}"/third_party -type f \( -name '*.so' -o -name '*.o' \) -print -delete || die

	# clear all vendor checksums so patches won't cause build failures
	# (no reason to do this manually)
	local crate
	while read crate; do
		crate="${crate##*/}"
		moz_clear_vendor_checksums "$crate"
	done < <(find "${S}/third_party/rust" -mindepth 1 -maxdepth 1 -type d)

	# Create build dir
	BUILD_DIR="${WORKDIR}/${PN}_build"
	mkdir -p "${BUILD_DIR}" || die

	xdg_environment_reset
}

src_configure() {
	# Show flags set at the beginning
	einfo "Current BINDGEN_CFLAGS:\t${BINDGEN_CFLAGS:-no value set}"
	einfo "Current CFLAGS:\t\t${CFLAGS:-no value set}"
	einfo "Current CXXFLAGS:\t\t${CXXFLAGS:-no value set}"
	einfo "Current LDFLAGS:\t\t${LDFLAGS:-no value set}"
	einfo "Current RUSTFLAGS:\t\t${RUSTFLAGS:-no value set}"

	local have_switched_compiler=
	if use clang; then
		# Force clang
		einfo "Enforcing the use of clang due to USE=clang ..."

		local version_clang=$(clang --version 2>/dev/null | grep -F -- 'clang version' | awk '{ print $3 }')
		[[ -n ${version_clang} ]] && version_clang=$(ver_cut 1 "${version_clang}")
		[[ -z ${version_clang} ]] && die "Failed to read clang version!"

		if tc-is-gcc; then
			have_switched_compiler=yes
		fi

		AR=llvm-ar
		CC=${CHOST}-clang-${version_clang}
		CXX=${CHOST}-clang++-${version_clang}
		NM=llvm-nm
		RANLIB=llvm-ranlib

	elif ! use clang && ! tc-is-gcc ; then
		# Force gcc
		have_switched_compiler=yes
		einfo "Enforcing the use of gcc due to USE=-clang ..."
		AR=gcc-ar
		CC=${CHOST}-gcc
		CXX=${CHOST}-g++
		NM=gcc-nm
		RANLIB=gcc-ranlib
	fi

	if [[ -n "${have_switched_compiler}" ]] ; then
		# Because we switched active compiler we have to ensure
		# that no unsupported flags are set
		strip-unsupported-flags
	fi

	# Ensure we use correct toolchain,
	# AS is used in a non-standard way by upstream, #bmo1654031
	export HOST_CC="$(tc-getBUILD_CC)"
	export HOST_CXX="$(tc-getBUILD_CXX)"
	export AS="$(tc-getCC) -c"
	tc-export CC CXX LD AR AS NM OBJDUMP RANLIB PKG_CONFIG

	# Pass the correct toolchain paths through cbindgen
	if tc-is-cross-compiler ; then
		export BINDGEN_CFLAGS="${SYSROOT:+--sysroot=${ESYSROOT}} --target=${CHOST} ${BINDGEN_CFLAGS-}"
	fi

	# Set MOZILLA_FIVE_HOME
	export MOZILLA_FIVE_HOME="/usr/$(get_libdir)/${PN}"

	# python/mach/mach/mixin/process.py fails to detect SHELL
	export SHELL="${EPREFIX}/bin/bash"

	# Set state path
	export MOZBUILD_STATE_PATH="${BUILD_DIR}"

	# Set MOZCONFIG
	export MOZCONFIG="${S}/.mozconfig"

	# Initialize MOZCONFIG
	mozconfig_add_options_ac '' --enable-application=browser
	mozconfig_add_options_ac '' --enable-project=browser

	# Set Gentoo defaults
	mozconfig_add_options_ac 'Gentoo default' \
		--allow-addon-sideload \
		--disable-cargo-incremental \
		--disable-crashreporter \
		--disable-eme \
		--disable-gpsd \
		--disable-install-strip \
		--disable-parental-controls \
		--disable-strip \
		--disable-tests \
		--disable-updater \
		--disable-wmf \
		--enable-legacy-profile-creation \
		--enable-negotiateauth \
		--enable-new-pass-manager \
		--enable-official-branding \
		--enable-release \
		--enable-system-ffi \
		--enable-system-pixman \
		--enable-system-policies \
		--host="${CBUILD:-${CHOST}}" \
		--libdir="${EPREFIX}/usr/$(get_libdir)" \
		--prefix="${EPREFIX}/usr" \
		--target="${CHOST}" \
		--without-ccache \
		--without-wasm-sandboxed-libraries \
		--with-intl-api \
		--with-libclang-path="$(llvm-config --libdir)" \
		--with-system-nspr \
		--with-system-nss \
		--with-system-zlib \
		--with-toolchain-prefix="${CHOST}-" \
		--with-unsigned-addon-scopes=app,system \
		--x-includes="${ESYSROOT}/usr/include" \
		--x-libraries="${ESYSROOT}/usr/$(get_libdir)"

	if ! use x86 && [[ ${CHOST} != armv*h* ]] ; then
		mozconfig_add_options_ac '' --enable-rust-simd
	fi

	# For future keywording: This is currently (97.0) only supported on:
	# amd64, arm, arm64 & x86.
	# Might want to flip the logic around if Firefox is to support more arches.
	# bug 833001, bug 903411#c8
	if use ppc64 || use riscv; then
		mozconfig_add_options_ac '' --disable-sandbox
	else
		mozconfig_add_options_ac '' --enable-sandbox
	fi

	# Enable JIT on riscv64 explicitly
	# Can be removed once upstream enable it by default in the future.
	use riscv && mozconfig_add_options_ac 'Enable JIT for RISC-V 64' --enable-jit

	mozconfig_use_with system-av1
	mozconfig_use_with system-harfbuzz
	mozconfig_use_with system-harfbuzz system-graphite2
	mozconfig_use_with system-icu
	mozconfig_use_with system-jpeg
	mozconfig_use_with system-libevent
	mozconfig_use_with system-libvpx
	mozconfig_use_with system-png
	mozconfig_use_with system-webp

	mozconfig_use_enable dbus
	mozconfig_use_enable libproxy

	mozconfig_use_enable geckodriver

	if use hardened ; then
		mozconfig_add_options_ac "+hardened" --enable-hardening
		append-ldflags "-Wl,-z,relro -Wl,-z,now"
	fi

	local myaudiobackends=""
	use jack && myaudiobackends+="jack,"
	use sndio && myaudiobackends+="sndio,"
	use pulseaudio && myaudiobackends+="pulseaudio,"
	! use pulseaudio && myaudiobackends+="alsa,"

	mozconfig_add_options_ac '--enable-audio-backends' --enable-audio-backends="${myaudiobackends::-1}"

	mozconfig_use_enable wifi necko-wifi

	if use X && use wayland ; then
		mozconfig_add_options_ac '+x11+wayland' --enable-default-toolkit=cairo-gtk3-x11-wayland
	elif ! use X && use wayland ; then
		mozconfig_add_options_ac '+wayland' --enable-default-toolkit=cairo-gtk3-wayland-only
	else
		mozconfig_add_options_ac '+x11' --enable-default-toolkit=cairo-gtk3
	fi

	if use lto ; then
		if use clang ; then
			# Upstream only supports lld or mold when using clang.
			if tc-ld-is-mold ; then
				mozconfig_add_options_ac "using ld=mold due to system selection" --enable-linker=mold
			else
				mozconfig_add_options_ac "forcing ld=lld due to USE=clang and USE=lto" --enable-linker=lld
			fi

			mozconfig_add_options_ac '+lto' --enable-lto=cross

		else
			# ThinLTO is currently broken, see bmo#1644409.
			# mold does not support gcc+lto combination.
			mozconfig_add_options_ac '+lto' --enable-lto=full
			mozconfig_add_options_ac "linker is set to bfd" --enable-linker=bfd
		fi

		if use pgo ; then
			mozconfig_add_options_ac '+pgo' MOZ_PGO=1

			if use clang ; then
				# Used in build/pgo/profileserver.py
				export LLVM_PROFDATA="llvm-profdata"
			fi
		fi
	else
		# Avoid auto-magic on linker
		if use clang ; then
			# lld is upstream's default
			if tc-ld-is-mold ; then
				mozconfig_add_options_ac "using ld=mold due to system selection" --enable-linker=mold
			else
				mozconfig_add_options_ac "forcing ld=lld due to USE=clang" --enable-linker=lld
			fi

		else
			if tc-ld-is-mold ; then
				mozconfig_add_options_ac "using ld=mold due to system selection" --enable-linker=mold
			else
				mozconfig_add_options_ac "linker is set to bfd due to USE=-clang" --enable-linker=bfd
			fi
		fi
	fi

	# LTO flag was handled via configure
	filter-lto

	mozconfig_use_enable debug
	if use debug ; then
		mozconfig_add_options_ac '+debug' --disable-optimize
		mozconfig_add_options_ac '+debug' --enable-real-time-tracing
	else
		mozconfig_add_options_ac 'Gentoo defaults' --disable-real-time-tracing

		if is-flag '-g*' ; then
			if use clang ; then
				mozconfig_add_options_ac 'from CFLAGS' --enable-debug-symbols=$(get-flag '-g*')
			else
				mozconfig_add_options_ac 'from CFLAGS' --enable-debug-symbols
			fi
		else
			mozconfig_add_options_ac 'Gentoo default' --disable-debug-symbols
		fi

		if is-flag '-O0' ; then
			mozconfig_add_options_ac "from CFLAGS" --enable-optimize=-O0
		elif is-flag '-O4' ; then
			mozconfig_add_options_ac "from CFLAGS" --enable-optimize=-O4
		elif is-flag '-O3' ; then
			mozconfig_add_options_ac "from CFLAGS" --enable-optimize=-O3
		elif is-flag '-O1' ; then
			mozconfig_add_options_ac "from CFLAGS" --enable-optimize=-O1
		elif is-flag '-Os' ; then
			mozconfig_add_options_ac "from CFLAGS" --enable-optimize=-Os
		else
			mozconfig_add_options_ac "Gentoo default" --enable-optimize=-O2
		fi
	fi

	# Debug flag was handled via configure
	filter-flags '-g*'

	# Optimization flag was handled via configure
	filter-flags '-O*'

	# Modifications to better support ARM, bug #553364
	if use cpu_flags_arm_neon ; then
		mozconfig_add_options_ac '+cpu_flags_arm_neon' --with-fpu=neon

		if ! tc-is-clang ; then
			# thumb options aren't supported when using clang, bug 666966
			mozconfig_add_options_ac '+cpu_flags_arm_neon' \
				--with-thumb=yes \
				--with-thumb-interwork=no
		fi
	fi

	if [[ ${CHOST} == armv*h* ]] ; then
		mozconfig_add_options_ac 'CHOST=armv*h*' --with-float-abi=hard

		if ! use system-libvpx ; then
			sed -i \
				-e "s|softfp|hard|" \
				"${S}"/media/libvpx/moz.build \
				|| die
		fi
	fi

	# With profile 23.0 elf-hack=legacy is broken with gcc.
	# With Firefox-115esr elf-hack=relr isn't available (only in rapid).
	# Solution: Disable build system's elf-hack completely, and add "-z,pack-relative-relocs"
	#  manually with gcc.
	#
	# elf-hack configure option isn't available on ppc64/riscv, #916259, #929244, #930046.
	if use ppc64 || use riscv ; then
		:;
	else
		mozconfig_add_options_ac 'elf-hack disabled' --disable-elf-hack
	fi

	if use amd64 || use x86 ; then
		! use clang && append-ldflags "-z,pack-relative-relocs"
	fi

	# Additional ARCH support
	case "${ARCH}" in
		arm)
			# Reduce the memory requirements for linking
			if use clang ; then
				# Nothing to do
				:;
			elif use lto ; then
				append-ldflags -Wl,--no-keep-memory
			else
				append-ldflags -Wl,--no-keep-memory -Wl,--reduce-memory-overheads
			fi
			;;
	esac

	if ! use elibc_glibc; then
		mozconfig_add_options_ac '!elibc_glibc' --disable-jemalloc
	fi

	# Allow elfhack to work in combination with unstripped binaries
	# when they would normally be larger than 2GiB.
	append-ldflags "-Wl,--compress-debug-sections=zlib"

	# Make revdep-rebuild.sh happy; Also required for musl
	append-ldflags -Wl,-rpath="${MOZILLA_FIVE_HOME}",--enable-new-dtags

	# Pass $MAKEOPTS to build system
	export MOZ_MAKE_FLAGS="${MAKEOPTS}"

	# Use system's Python environment
	export PIP_NETWORK_INSTALL_RESTRICTED_VIRTUALENVS=mach

	if use system-python-libs; then
		export MACH_BUILD_PYTHON_NATIVE_PACKAGE_SOURCE="system"
	else
		export MACH_BUILD_PYTHON_NATIVE_PACKAGE_SOURCE="none"
	fi

	# Disable notification when build system has finished
	export MOZ_NOSPAM=1

	# Portage sets XARGS environment variable to "xargs -r" by default which
	# breaks build system's check_prog() function which doesn't support arguments
	mozconfig_add_options_ac 'Gentoo default' "XARGS=${EPREFIX}/usr/bin/xargs"

	# Set build dir
	mozconfig_add_options_mk 'Gentoo default' "MOZ_OBJDIR=${BUILD_DIR}"

	# Show flags we will use
	einfo "Build BINDGEN_CFLAGS:\t${BINDGEN_CFLAGS:-no value set}"
	einfo "Build CFLAGS:\t\t${CFLAGS:-no value set}"
	einfo "Build CXXFLAGS:\t\t${CXXFLAGS:-no value set}"
	einfo "Build LDFLAGS:\t\t${LDFLAGS:-no value set}"
	einfo "Build RUSTFLAGS:\t\t${RUSTFLAGS:-no value set}"

	# Handle EXTRA_CONF and show summary
	local ac opt hash reason

	# Apply EXTRA_ECONF entries to $MOZCONFIG
	if [[ -n ${EXTRA_ECONF} ]] ; then
		IFS=\! read -a ac <<<${EXTRA_ECONF// --/\!}
		for opt in "${ac[@]}"; do
			mozconfig_add_options_ac "EXTRA_ECONF" --${opt#--}
		done
	fi

	echo
	echo "=========================================================="
	echo "Building ${PF} with the following configuration"
	grep ^ac_add_options "${MOZCONFIG}" | while read ac opt hash reason; do
		[[ -z ${hash} || ${hash} == \# ]] \
			|| die "error reading mozconfig: ${ac} ${opt} ${hash} ${reason}"
		printf "    %-30s  %s\n" "${opt}" "${reason:-mozilla.org default}"
	done
	echo "=========================================================="
	echo

	./mach configure || die
}

src_compile() {
	local virtx_cmd=

	if tc-ld-is-mold && use lto; then
		# increase ulimit with mold+lto, bugs #892641, #907485
		if ! ulimit -n 16384 1>/dev/null 2>&1 ; then
			ewarn "Unable to modify ulimits - building with mold+lto might fail due to low ulimit -n resources."
			ewarn "Please see bugs #892641 & #907485."
		else
			ulimit -n 16384
		fi
	fi

	if use pgo; then
		# Reset and cleanup environment variables used by GNOME/XDG
		gnome2_environment_reset

		addpredict /root

		if ! use X; then
			virtx_cmd=virtwl
		else
			virtx_cmd=virtx
		fi
	fi

	if ! use X; then
		local -x GDK_BACKEND=wayland
	else
		local -x GDK_BACKEND=x11
	fi

	${virtx_cmd} ./mach build --verbose || die
}

src_install() {
	# xpcshell is getting called during install
	pax-mark m \
		"${BUILD_DIR}"/dist/bin/xpcshell \
		"${BUILD_DIR}"/dist/bin/${PN} \
		"${BUILD_DIR}"/dist/bin/plugin-container

	DESTDIR="${D}" ./mach install || die

	# Upstream cannot ship symlink but we can (bmo#658850)
	rm "${ED}${MOZILLA_FIVE_HOME}/${PN}-bin" || die
	dosym ${PN} ${MOZILLA_FIVE_HOME}/${PN}-bin

	# Don't install llvm-symbolizer from sys-devel/llvm package
	if [[ -f "${ED}${MOZILLA_FIVE_HOME}/llvm-symbolizer" ]] ; then
		rm -v "${ED}${MOZILLA_FIVE_HOME}/llvm-symbolizer" || die
	fi

	# Install policy (currently only used to disable application updates)
	insinto "${MOZILLA_FIVE_HOME}/distribution"
	newins "${FILESDIR}"/distribution.ini distribution.ini

	# more tweaks
	if use custom-fixes; then
		# install enterprise policy
		newins "${FILESDIR}/policies.json" policies.json
		insinto "${MOZILLA_FIVE_HOME}"

		# get config filename from autoconfig.js
		local name="$(grep 'general\.config\.filename' "${FILESDIR}/autoconfig.js" \
			| cut -d, -f2 | grep -o '"[^"]\+"' | cut -d\" -f2)"

		# construct autoconfig.js
		echo "// autoconfig.js generated on $(date --rfc-email)"$'\n' > "${T}/autoconfig.js"
		cat "${FILESDIR}/autoconfig.js" >> "${T}/autoconfig.js"
		# this is not needed yet as of ESR 102
		use userchrome-js && echo $'\n'"pref(\"general.config.sandbox\", 0);" >> "${T}/autoconfig.js"

		# construct config file
		echo "// ${name} generated on $(date --rfc-email)"$'\n' > "${T}/${name}"
		cat "${FILESDIR}/prefs.js" >> "${T}/${name}"
		if use userchrome-js; then
			echo >> "${T}/${name}"
			cat "${FILESDIR}/loader.js" >> "${T}/${name}"
		fi

		# install config file and autoconfig.js
		newins "${T}/${name}" "${name}"
		insinto "${MOZILLA_FIVE_HOME}/defaults/pref"
		newins "${T}/autoconfig.js" autoconfig.js
	else
		# use default Gentoo policy
		newins "${FILESDIR}"/disable-auto-update.policy.json policies.json
	fi

	# Install system-wide preferences
	local PREFS_DIR="${MOZILLA_FIVE_HOME}/browser/defaults/preferences"
	insinto "${PREFS_DIR}"
	newins "${FILESDIR}"/gentoo-default-prefs.js gentoo-prefs.js

	local GENTOO_PREFS="${ED}${PREFS_DIR}/gentoo-prefs.js"

	# Set dictionary path to use system hunspell
	cat >>"${GENTOO_PREFS}" <<-EOF || die "failed to set spellchecker.dictionary_path pref"
	pref("spellchecker.dictionary_path",       "${EPREFIX}/usr/share/myspell");
	EOF

	# Force hwaccel prefs if USE=hwaccel is enabled
	if use hwaccel ; then
		cat "${FILESDIR}"/gentoo-hwaccel-prefs.js-r2 \
		>>"${GENTOO_PREFS}" \
		|| die "failed to add prefs to force hardware-accelerated rendering to all-gentoo.js"

		if use wayland; then
			cat >>"${GENTOO_PREFS}" <<-EOF || die "failed to set hwaccel wayland prefs"
			pref("gfx.x11-egl.force-enabled",          false);
			EOF
		else
			cat >>"${GENTOO_PREFS}" <<-EOF || die "failed to set hwaccel x11 prefs"
			pref("gfx.x11-egl.force-enabled",          true);
			EOF
		fi
	fi

	# Force the graphite pref if USE=system-harfbuzz is enabled, since the pref cannot disable it
	if use system-harfbuzz ; then
		cat >>"${GENTOO_PREFS}" <<-EOF || die "failed to set gfx.font_rendering.graphite.enabled pref"
		sticky_pref("gfx.font_rendering.graphite.enabled", true);
		EOF
	fi

	# Install language packs
	#local langpacks=( $(find "${WORKDIR}/language_packs" -type f -name '*.xpi') )
	#if [[ -n "${langpacks}" ]] ; then
	#	moz_install_xpi "${MOZILLA_FIVE_HOME}/distribution/extensions" "${langpacks[@]}"
	#fi

	# Install geckodriver
	if use geckodriver ; then
		einfo "Installing geckodriver into ${ED}${MOZILLA_FIVE_HOME} ..."
		pax-mark m "${BUILD_DIR}"/dist/bin/geckodriver
		exeinto "${MOZILLA_FIVE_HOME}"
		doexe "${BUILD_DIR}"/dist/bin/geckodriver

		dosym ${MOZILLA_FIVE_HOME}/geckodriver /usr/bin/geckodriver
	fi

	# Install icons
	local icon_srcdir="${S}/browser/branding/official"
	local icon_symbolic_file="${FILESDIR}/icon/${PN}-symbolic.svg"

	insinto /usr/share/icons/hicolor/symbolic/apps
	newins "${icon_symbolic_file}" ${PN}-symbolic.svg

	local icon size
	for icon in "${icon_srcdir}"/default*.png ; do
		size=${icon%.png}
		size=${size##*/default}

		if [[ ${size} -eq 48 ]] ; then
			newicon "${icon}" ${PN}.png
		fi

		newicon -s ${size} "${icon}" ${PN}.png
	done

	# Install menu
	local app_name="GNU IceCat"
	local desktop_file="${FILESDIR}/icon/${PN}-r3.desktop"
	local desktop_filename="${PN}.desktop"
	local exec_command="${PN}"
	local icon="${PN}"
	local use_wayland="false"

	if use wayland ; then
		use_wayland="true"
	fi

	cp "${desktop_file}" "${WORKDIR}/${PN}.desktop-template" || die

	sed -i \
		-e "s:@NAME@:${app_name}:" \
		-e "s:@EXEC@:${exec_command}:" \
		-e "s:@ICON@:${icon}:" \
		"${WORKDIR}/${PN}.desktop-template" \
		|| die

	newmenu "${WORKDIR}/${PN}.desktop-template" "${desktop_filename}"

	rm "${WORKDIR}/${PN}.desktop-template" || die

	# Install wrapper script
	[[ -f "${ED}/usr/bin/${PN}" ]] && rm "${ED}/usr/bin/${PN}"
	newbin "${FILESDIR}/${PN}-r1.sh" ${PN}

	# Update wrapper
	sed -i \
		-e "s:@PREFIX@:${EPREFIX}/usr:" \
		-e "s:@MOZ_FIVE_HOME@:${MOZILLA_FIVE_HOME}:" \
		-e "s:@APULSELIB_DIR@:${apulselib}:" \
		-e "s:@DEFAULT_WAYLAND@:${use_wayland}:" \
		"${ED}/usr/bin/${PN}" \
		|| die
}

pkg_preinst() {
	xdg_pkg_preinst

	# If the apulse libs are available in MOZILLA_FIVE_HOME then apulse
	# does not need to be forced into the LD_LIBRARY_PATH
	if use pulseaudio && has_version ">=media-sound/apulse-0.1.12-r4" ; then
		einfo "APULSE found; Generating library symlinks for sound support ..."
		local lib
		pushd "${ED}${MOZILLA_FIVE_HOME}" &>/dev/null || die
		for lib in ../apulse/libpulse{.so{,.0},-simple.so{,.0}} ; do
			# A quickpkg rolled by hand will grab symlinks as part of the package,
			# so we need to avoid creating them if they already exist.
			if [[ ! -L ${lib##*/} ]] ; then
				ln -s "${lib}" ${lib##*/} || die
			fi
		done
		popd &>/dev/null || die
	fi
}

pkg_postinst() {
	xdg_pkg_postinst

	if use pulseaudio && has_version ">=media-sound/apulse-0.1.12-r4" ; then
		elog "Apulse was detected at merge time on this system and so it will always be"
		elog "used for sound.  If you wish to use pulseaudio instead please unmerge"
		elog "media-sound/apulse."
		elog
	fi

	# bug 835078
	if use hwaccel && has_version "x11-drivers/xf86-video-nouveau"; then
		ewarn "You have nouveau drivers installed in your system and 'hwaccel' "
		ewarn "enabled for IceCat. Nouveau / your GPU might not support the "
		ewarn "required EGL, so either disable 'hwaccel' or try the workaround "
		ewarn "explained in https://bugs.gentoo.org/835078#c5 if IceCat crashes."
	fi

	optfeature_header "Optional programs for extra features:"
	optfeature "desktop notifications" x11-libs/libnotify
	optfeature "fallback mouse cursor theme e.g. on WMs" gnome-base/gsettings-desktop-schemas

	if use hwaccel && has_version "x11-drivers/nvidia-drivers"; then
		optfeature "hardware acceleration with NVIDIA cards" media-libs/nvidia-vaapi-driver
	fi
}
