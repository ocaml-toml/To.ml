# Customized version of http://blog.mlin.net/2013/02/testing-ocaml-projects-on-travis-ci.html

# OPAM version to install
export OPAM_VERSION=1.1.0
# OPAM packages needed to build tests
export OPAM_PACKAGES='ocamlfind ounit menhir'

# install ocaml from apt
sudo apt-get update -qq
sudo apt-get install -qq ocaml

# install opam
curl https://github.com/OCamlPro/opam/archive/${OPAM_VERSION}.tar.gz | tar xz -C /tmp
pushd /tmp/opam-${OPAM_VERSION}
./configure
make
sudo make install
opam init -a
eval `opam config -env`
popd

# install packages from opam
opam install -q -y ${OPAM_PACKAGES}

make test
