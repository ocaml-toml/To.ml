# Customized version of http://blog.mlin.net/2013/02/testing-ocaml-projects-on-travis-ci.html

# OPAM version to install
export OPAM_VERSION=1.1.0
# OPAM packages needed to build tests
export OPAM_PACKAGES='ocamlfind ounit menhir'

echo '** INSTALLING OCAML'

# install ocaml from apt
sudo add-apt-repository ppa:mike-mcclurg/ocaml -y
sudo add-apt-repository ppa:avsm/ppa -y
sudo apt-get update -qq
sudo apt-get install -qq ocaml opam

opam init -a
eval `opam  config -env`

echo '** INSTALING DEPENDENCIES'

# install packages from opam
opam install -q -y ${OPAM_PACKAGES}

echo '** TEST'

make test
