# no license, fuck you

EAPI=7

CRATES="
aho-corasick-0.7.15
ansi_term-0.11.0
async-channel-1.6.1
async-executor-1.4.0
async-global-executor-2.0.2
async-io-1.3.1
async-lock-2.3.0
async-mutex-1.4.0
async-std-1.9.0
async-task-4.0.3
atomic-waker-1.0.0
atty-0.2.14
autocfg-1.0.1
bitflags-1.2.1
blocking-1.0.2
bumpalo-3.6.1
bytes-0.5.6
bytes-1.0.1
cache-padded-1.1.1
cc-1.0.67
cfg-if-0.1.10
cfg-if-1.0.0
clap-2.33.3
concurrent-queue-1.2.2
crossbeam-utils-0.8.3
ctor-0.1.19
env_logger-0.7.1
event-listener-2.5.1
fastrand-1.4.0
fnv-1.0.7
fuchsia-zircon-0.3.3
fuchsia-zircon-sys-0.3.3
futures-0.3.13
futures-channel-0.3.13
futures-core-0.3.13
futures-executor-0.3.13
futures-io-0.3.13
futures-lite-1.11.3
futures-macro-0.3.13
futures-sink-0.3.13
futures-task-0.3.13
futures-util-0.3.13
gloo-timers-0.2.1
heck-0.3.2
hermit-abi-0.1.18
humantime-1.3.0
instant-0.1.9
iovec-0.1.4
itoa-0.4.7
js-sys-0.3.48
kernel32-sys-0.2.2
kv-log-macro-1.0.7
lazy_static-1.4.0
libc-0.2.87
libpulse-binding-2.23.0
libpulse-sys-1.18.0
log-0.4.14
memchr-2.3.4
mio-0.6.23
mio-0.7.10
mio-uds-0.6.8
miow-0.2.2
miow-0.3.6
nb-connect-1.0.3
net2-0.2.37
nix-0.15.0
ntapi-0.3.6
num-derive-0.3.3
num-traits-0.2.14
num_cpus-1.13.0
once_cell-1.7.2
parking-2.0.0
pin-project-lite-0.1.12
pin-project-lite-0.2.5
pin-utils-0.1.0
pkg-config-0.3.19
polling-2.0.2
proc-macro-error-1.0.4
proc-macro-error-attr-1.0.4
proc-macro-hack-0.5.19
proc-macro-nested-0.1.7
proc-macro2-1.0.24
quick-error-1.2.3
quote-1.0.9
regex-1.4.3
regex-syntax-0.6.22
ryu-1.0.5
serde-1.0.123
serde_derive-1.0.123
serde_json-1.0.64
signal-hook-registry-1.3.0
slab-0.4.2
socket2-0.3.19
strsim-0.8.0
structopt-0.3.21
structopt-derive-0.4.14
syn-1.0.60
termcolor-1.1.2
textwrap-0.11.0
thread_local-1.1.3
tokio-0.2.25
tokio-1.3.0
tokio-macros-0.2.6
tokio-macros-1.1.0
unicode-segmentation-1.7.1
unicode-width-0.1.8
unicode-xid-0.2.1
value-bag-1.0.0-alpha.6
vec-arena-1.0.0
vec_map-0.8.2
version_check-0.9.2
void-1.0.2
waker-fn-1.1.0
wasm-bindgen-0.2.71
wasm-bindgen-backend-0.2.71
wasm-bindgen-futures-0.4.21
wasm-bindgen-macro-0.2.71
wasm-bindgen-macro-support-0.2.71
wasm-bindgen-shared-0.2.71
web-sys-0.3.48
wepoll-sys-3.0.1
winapi-0.2.8
winapi-0.3.9
winapi-build-0.1.1
winapi-i686-pc-windows-gnu-0.4.0
winapi-util-0.1.5
winapi-x86_64-pc-windows-gnu-0.4.0
ws2_32-sys-0.2.1
x11-2.18.2
xcb-0.9.0
"

inherit cargo

DESCRIPTION="A general-purpose replacement for xautolock."
HOMEPAGE="https://gitlab.com/jD91mZM2/xidlehook"
SRC_URI="
	https://gitlab.com/jD91mZM2/xidlehook/-/archive/${PV}/xidlehook-${PV}.tar.gz
	$(cargo_crate_uris ${CRATES})
"
LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
RESTRICT="mirror"
IUSE="pulseaudio"

# not sure if xidlehook plays nicely with apulse
# the repository doesn't specify library versions
# so we just assume that the current ones work
RDEPEND="
	pulseaudio? ( media-sound/pulseaudio )
	x11-libs/libxcb
	x11-libs/libXScrnSaver
"
DEPEND="
	${RUST_DEPEND}
	${RDEPEND}
"

src_configure() {
	local myfeatures=( $(usex pulseaudio pulse '') )
	cargo_src_configure --no-default-features
}

src_install() {
	cargo_src_install --path xidlehook-daemon

	# install helper scripts
	exeinto /usr/share/xidlehook
	doexe "${FILESDIR}/xidlehook.sh"
	doexe "${FILESDIR}/xidlehook_start.sh"
	doexe "${FILESDIR}/xidlehook_stop.sh"
}

pkg_postinst() {
	einfo "You can use the scripts located in /usr/share/xidlehook"
	einfo "to integarate xidlehook with your DE. (you should write"
	einfo "your own as they're quite shitty.)"
}
