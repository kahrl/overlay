# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4

inherit toolchain-funcs

DESCRIPTION="Generate sound effects"
HOMEPAGE="http://www.drpetter.se/project_sfxr.html"
SRC_URI="http://www.drpetter.se/files/${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="media-libs/libsdl
	>=x11-libs/gtk+-2"
RDEPEND="${DEPEND}"

RESTRICT="mirror"

src_compile() {
	tc-export CXX
	emake
}

src_install() {
	emake DESTDIR="${D}" install
	dodoc ChangeLog readme.txt
}
