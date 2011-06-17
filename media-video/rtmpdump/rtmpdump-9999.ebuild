# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4

inherit git-2 multilib toolchain-funcs

EGIT_REPO_URI="git://git.ffmpeg.org/rtmpdump"
DESCRIPTION="Open source command-line RTMP client intended to stream audio or video flash content"
HOMEPAGE="http://rtmpdump.mplayerhq.hu/"
if [[ ${PV} == *9999* ]]; then
	SRC_URI=""
else
	SRC_URI="http://rtmpdump.mplayerhq.hu/download/${P}.tgz"
fi

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~hppa ~ppc ~ppc64 ~x86"
IUSE="gnutls polarssl ssl"

DEPEND="ssl? (
		gnutls? ( net-libs/gnutls )
		polarssl? ( !gnutls? ( >=net-libs/polarssl-0.14.0 ) )
		!gnutls? ( !polarssl? ( dev-libs/openssl ) )
	)
	sys-libs/zlib"
RDEPEND="${DEPEND}"

pkg_setup() {
	if [[ ${PV} == *9999* ]]; then
		elog
		elog "This is a live ebuild which installs the latest from upstream's"
		elog "git repository, and is unsupported by Gentoo."
		elog "Everything but bugs in the ebuild itself will be ignored."
		elog
	fi

	if ! use ssl && ( use gnutls ||	use polarssl ) ; then
		ewarn "USE='gnutls polarssl' are ignored without USE='ssl'."
		ewarn "Please review the local USE flags for this package."
	fi
}

src_unpack() {
	if [[ ${PV} == *9999* ]]; then
		git-2_src_unpack
	else
		unpack ${A}
	fi
}

src_prepare() {
	# fix Makefile ( bug #298535 , bug #318353 and bug #324513 )
	sed -i 's/\$(MAKEFLAGS)//g' Makefile \
		|| die "failed to fix Makefile"
	sed -i -e 's:OPT=:&-fPIC :' \
		-e 's:OPT:OPTS:' \
		-e 's:CFLAGS=.*:& $(OPT):' librtmp/Makefile \
		|| die "failed to fix Makefile"

	if [[ ${PV} == *9999* ]]; then
		sed -i -e "s:^VERSION=.*$:VERSION=v${ESVN_WC_REVISION}-svn:" Makefile \
			|| die "failed to fix Makefile"
	fi
}

src_compile() {
	if use ssl ; then
		if use gnutls ;	then
			crypto="GNUTLS"
		elif use polarssl ; then
			crypto="POLARSSL"
		else
			crypto="OPENSSL"
		fi
	fi
	#fix multilib-script support. Bug #327449
	sed -i "/^libdir/s:lib$:$(get_libdir)$:" librtmp/Makefile
	emake CC=$(tc-getCC) LD=$(tc-getLD) \
		OPT="${CFLAGS}" XLDFLAGS="${LDFLAGS}" CRYPTO="${crypto}" SYS=posix
}

src_install() {
	mkdir -p "${D}"/${DESTTREE}/$(get_libdir)
	emake DESTDIR="${D}" prefix="${DESTTREE}" mandir="${DESTTREE}/share/man" \
	CRYPTO="${crypto}" install
	dodoc README ChangeLog
	dohtml rtmpdump.1.html rtmpgw.8.html
}
