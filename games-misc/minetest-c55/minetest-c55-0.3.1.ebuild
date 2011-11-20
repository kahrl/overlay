# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

# switch to EAPI=4 once games.eclass supports it
EAPI=3

# cmake-utils needs to be last, we want its src_compile
inherit eutils games versionator cmake-utils

MY_PN="minetest"
MY_PV=$(replace_version_separator 3 '_')
MY_P="${PN}-${MY_PV}"
MY_CHANGESET="bc0e5c0"

RESTRICT="mirror"

DESCRIPTION="A minecraft clone"
HOMEPAGE="http://c55.me/minetest/"
SRC_URI="https://github.com/celeron55/${MY_PN}/zipball/${MY_PV} -> ${MY_P}.zip"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="+client nls +server"

LANGS="da de fr it"
for l in ${LANGS}; do
	IUSE="${IUSE} linguas_${l/-/_}"
done

DEPEND="app-arch/bzip2
	dev-db/sqlite:3
	>=dev-games/irrlicht-1.7
	dev-libs/jthread
	media-libs/libpng
	nls? ( sys-devel/gettext )
	sys-libs/zlib
	virtual/jpeg
	virtual/opengl
	x11-libs/libX11
	x11-libs/libXxf86vm"
RDEPEND="${DEPEND}"

S="${WORKDIR}/celeron55-minetest-${MY_CHANGESET}"

src_prepare() {
	epatch "${FILESDIR}"/minetest-find-share-games-0.3.1.patch
}

src_configure() {
	mycmakeargs="
		-DRUN_IN_PLACE=0
		$(cmake-utils_use_build client CLIENT)
		$(cmake-utils_use_build server SERVER)
		$(cmake-utils_use_use nls GETTEXT)"

	# FindJthread.cmake module needs some help finding headers
	mycmakeargs="${mycmakeargs}
		-DJTHREAD_INCLUDE_DIR=${EROOT}/usr/include/jthread"

	cmake-utils_src_configure
}

src_install() {
	# We do the installation ourselves for the following reasons:
	# (1) CMakeLists.txt doesn't respect the destination paths defined
	#     by games.eclass, it doesn't seem to provide an easy way to
	#     replace the destination directories (apart from patching), and
	#     writing a patch to make CMakeLists.txt grab the destination
	#     paths from the environment isn't trivial (although not hard either).
	# (2) The build system always wants to install all locales, even
	#     those not in LINGUAS.
	# (3) CMake installs documentation to /usr/share/doc/minetest, not
	#     /usr/share/doc/minetest-${PV} as is customary on gentoo.
	# (4) CMake installs locales to /usr/locale, not /usr/share/locale.
	#     (Although patching this would be trivial.)

	_check_build_dir  # determine CMAKE_BUILD_DIR

	if use client; then
		einfo "Installing client binary (minetest)"
		dogamesbin bin/minetest

		einfo "Installing data"
		insinto "${GAMES_DATADIR}"/${MY_PN}
		doins data/*.png

		if use nls; then
			# There is a po/en directory, but it only contains a .pot file,
			# so we never install it.
			einfo "Installing .mo files"
			for l in ${LANGS}; do
				if use linguas_${l/-/_}; then
					insinto /usr/share/locale/${l}/LC_MESSAGES
					doins "${CMAKE_BUILD_DIR}"/locale/${l}/LC_MESSAGES/${MY_PN}.mo
				fi
			done
		fi
	fi

	if use server; then
		einfo "Installing server binary (minetestserver)"
		dogamesbin bin/minetestserver
	fi

	einfo "Installing documentation"
	dodoc README.txt
	dodoc minetest.conf.example
	dodoc doc/changelog.txt
	dodoc doc/mapformat.txt
	dodoc doc/protocol.txt
}
