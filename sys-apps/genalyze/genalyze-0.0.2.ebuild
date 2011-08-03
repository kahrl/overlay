# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4

DESCRIPTION="A tool used to gather system information and paste it online"
HOMEPAGE="https://sf.net/p/gentoo-genalyze"
SRC_URI="https://sourceforge.net/projects/gentoo-genalyze/files/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="alpha amd64 hppa ia64 ppc ppc64 sparc x86"
IUSE=""

DEPEND="app-text/wgetpaste
	sys-apps/pciutils"
RDEPEND="${DEPEND}"

src_install() {
	dodoc README
	dobin genalyze
}
