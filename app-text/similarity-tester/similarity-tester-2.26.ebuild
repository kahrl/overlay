# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4

inherit eutils toolchain-funcs versionator

MY_PV=$(replace_all_version_separators _)
DESCRIPTION="Finds similarities between files"
HOMEPAGE="http://dickgrune.com/Programs/similarity_tester/"
SRC_URI="http://dickgrune.com/Programs/similarity_tester/sim_${MY_PV}.zip"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="app-arch/unzip
	sys-devel/flex"

S=${WORKDIR}

src_prepare() {
	epatch "${FILESDIR}"/${P}-fix-configuration.patch
}

src_compile() {
	tc-export CC
	emake all
}

src_install() {
	emake DESTDIR="${D}" install
	dodoc Answers ChangeLog READ_ME README.1ST TechnReport ToDo VERSION
	dohtml sim.html
}
