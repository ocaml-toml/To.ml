# custom .travis-ci.sh
# based on http://anil.recoil.org/2013/09/30/travis-and-ocaml.html
OPAM_DEPENDS="ocamlfind ounit menhir"

case "$OCAML_VERSION,$OPAM_VERSION" in
3.12.1,1.0.0) ppa=avsm/ocaml312+opam10 ;;
3.12.1,1.1.0) ppa=avsm/ocaml312+opam11 ;;
4.00.1,1.0.0) ppa=avsm/ocaml40+opam10 ;;
4.00.1,1.1.0) ppa=avsm/ocaml40+opam11 ;;
4.01.0,1.0.0) ppa=avsm/ocaml41+opam10 ;;
4.01.0,1.1.0) ppa=avsm/ocaml41+opam11 ;;
4.02.0,1.2.0) ppa=avsm/ocaml42+opam12 ;;
*) echo Unknown $OCAML_VERSION,$OPAM_VERSION; exit 1 ;;
esac

echo '** INSTALLING DEPENDENCIES'
echo "yes" | sudo add-apt-repository ppa:$ppa
sudo apt-get update -qq
sudo apt-get install -qq ocaml ocaml-native-compilers camlp4-extra opam
export OPAMYES=1
opam init
opam install ${OPAM_DEPENDS}
eval `opam config env`

# install patched bisect library since it is not updated on opam yet
echo '** INSTALLING PATCHED BISECT LIBRARY'
wget http://bisect.sagotch.fr/ -O Bisect.tar.gz
tar -xvf Bisect.tar.gz
cd Bisect
chmod +x configure
./configure
cat Makefile.config
make all
sudo make install # ./configure set PATH_OCAML_PREFIX=/usr instead of
                  # using .opam directory, so we need sudo
cd ..

# run test, then send result to coveralls
echo '** TEST CODE COVERAGE'
make coverage
