# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=3

inherit toolchain-funcs

DESCRIPTION="Plays a sine wave via the dsp or standard out"
HOMEPAGE="http://www.lns.com/papers/tonegen/"
SRC_URI="http://ompldr.org/vYWhsZw/tonegen-1.5.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND=""
RDEPEND="${DEPEND}"

RESTRICT="mirror"

src_compile()
{
	$(tc-getCC) -DLINUX -include string.h -c -o ${PN}.o ${PN}.c || die "compile step failed"
	$(tc-getCC) -o ${PN} ${PN}.o -lm || die "link step failed"
}

src_install()
{
	dobin ${PN}
}
