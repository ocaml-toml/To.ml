# Customized version of http://blog.mlin.net/2013/02/testing-ocaml-projects-on-travis-ci.html

# OPAM version to install
export OPAM_VERSION=1.1.0
# OPAM packages needed to build tests
export OPAM_PACKAGES='ocamlfind ounit menhir'

echo '** INSTALLING OCAML'

# install ocaml from apt
sudo apt-get update -qq
sudo apt-get install -qq ocaml

echo '** INSTALLING OPAM'

# install opam
pushd /tmp
curl https://codeload.github.com/ocaml/opam/tar.gz/${OPAM_VERSION} | tar xz /tmp/opam-${OPAM_VERSION}
pushd /tmp/opam-${OPAM_VERSION}
./configure > /dev/null
make 2> /dev/null
sudo make install > /dev/null 2> /dev/null
opam init -a
eval `opam config -env`
popd
popd

echo '** INSTALING DEPENDENCIES'

# install packages from opam
opam install -q -y ${OPAM_PACKAGES}

echo '** TEST'

make test
