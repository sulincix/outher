. PKGBUILD
pwd=$(pwd)
wget -c $source
tar -xf *.tar.*
export pkgdir=$pwd/install
export srcdir=.
cd $pwd
pkgver
cd $pwd
prepare
cd $pwd
build
cd $pwd
package
cd $pwd
