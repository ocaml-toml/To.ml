# custom .travis-ci.sh
# based on http://anil.recoil.org/2013/09/30/travis-and-ocaml.html

######
# Configuration variables
######

OPAM_DEPENDS="ocamlfind oasis ounit menhir"
BISECT_URL="http://bisect.sagotch.fr/ "

########
#  Some utilities in order to ease printing
#######

set +x # dont output all commmands
tput init # initialize termcap if not already done

# colors
RED=$(tput setaf 1)
YELLOW=$(tput setaf 3)
LIME_GREEN=$(tput setaf 2)
CYAN=$(tput setaf 6)

BOLD=$(tput bold)
STANDOUT=$(tput smso)
ExSTANDOUT=$(tput rmso)

RESET=$(tput sgr0)

function error() {
  echo ${RED}'!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'
  echo ${STANDOUT}'!!! ERROR !!!'${ExSTANDOUT}
  echo ${BOLD}${RED}${*}${RESET}
  echo ${RED}'!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'${RESET}
  exit 1
}

step_counter=0
substep_counter=0

function step() {
  step_counter=$((1 + $step_counter))
  echo -n ${CYAN}'===['
  echo -n ${LIME_GREEN}${BOLD}${step_counter}${RESET}
  echo -n ${CYAN}'] '
  echo -n ${YELLOW}${BOLD}"$1"${RESET}
  echo ${CYAN}' =============================='${RESET}

  substep_counter=0
}

function substep() {
  substep_counter=$((1 + $substep_counter))
  echo -n ${CYAN}'====['
  echo -n ${LIME_GREEN}"${step_counter}.${substep_counter}"
  echo -n ${CYAN}']  '
  echo -n ${YELLOW}${*}
  echo ${CYAN}' =============================='${RESET}
}

function cmd_step() {
  substep "$*"
  eval $*
}

#######
# End of utilities
#######

step "SETUP OCAML AND OPAM"

case "$OCAML_VERSION,$OPAM_VERSION" in
3.12.1,1.0.0) ppa=avsm/ocaml312+opam10 ;;
3.12.1,1.1.0) ppa=avsm/ocaml312+opam11 ;;
4.00.1,1.0.0) ppa=avsm/ocaml40+opam10 ;;
4.00.1,1.1.0) ppa=avsm/ocaml40+opam11 ;;
4.01.0,1.0.0) ppa=avsm/ocaml41+opam10 ;;
4.01.0,1.1.0) ppa=avsm/ocaml41+opam11 ;;
4.01.0,1.2.0) ppa=avsm/ocaml41+opam12 ;;
4.02.1,1.2.0) ppa=avsm/ocaml42+opam12 ;;
*) error "Unknown ocaml or opam version: $OCAML_VERSION,$OPAM_VERSION";;
esac

step 'INSTALLING DEPENDENCIES'

substep 'aptitude install'
echo "yes" | sudo add-apt-repository ppa:$ppa
sudo apt-get update -qq
sudo apt-get install -qq ocaml ocaml-native-compilers camlp4-extra opam

export OPAMYES=1
cmd_step opam init
cmd_step opam install ${OPAM_DEPENDS}
eval `opam config env`

substep 'patch broken path lookup'
pushd `opam config var bin`
for bin in /usr/bin/*caml*
do
    echo ${LIME_GREEN}*${RESET} linking ${bin}${RESET}
    ln -s $bin
done
popd

# install patched bisect library since it is not updated on opam yet
step 'INSTALLING PATCHED BISECT LIBRARY'
substep 'download'
wget $BISECT_URL -O Bisect.tar.gz

substep 'extraction'
tar -xvf Bisect.tar.gz

substep 'configure'
pushd Bisect
chmod +x configure
./configure -ocaml-prefix `opam config var prefix`

cmd_step cat Makefile.config

cmd_step make all

cmd_step make install
#sudo make install # ./configure set PATH_OCAML_PREFIX=/usr instead of
                  # using .opam directory, so we need sudo
popd

# run test, then send result to coveralls
step 'TEST CODE COVERAGE'
cmd_step oasis setup
substep 'configure Toml'
./configure --enable-tests --enable-report
cmd_step make test
