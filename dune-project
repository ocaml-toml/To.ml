(lang dune 2.7)
(name toml)

(using menhir 2.0)

(license LGPL3)

(authors "Julien Sagot" "Emmanuel Surleau" "mackwic" "Andrew Rudenko"
  "orbifx" "c-cube")

(maintainers "OCamlPro <contact@ocamlpro.com>")

(source
 (github ocaml-toml/To.ml))

(homepage https://ocaml-toml.github.io/To.ml/)

(documentation https://ocaml-toml.github.io/To.ml/api/)

(generate_opam_files true)

(package
 (name toml)
 (synopsis "Library for TOML with a parser, a serializer and a printer")
 (description
   "toml is an OCaml library providing a parser, a serializer and a printer for TOML, a minimal configuration file format. Helpful getters to retrieve data as OCaml primitive types are also supplied.")
 (depends
  (ocaml
   (>= 4.07))
  (dune
   (>= 2.7))
  (menhir :build)
  (ounit2 :with-test)
  (bisect_ppx
   (and
    :with-test
    (>= "2.5")
    :dev))
  (ocb
   (and
    :with-test
    (>= "0.1")
    :dev))
  (odoc :with-doc)
  (ISO8601
   (>= 0.2))))

(package
 (name toml_cconv)
 (synopsis "Interface between cconv and toml")
 (description "Allows to use TOML encoding and decoding with cconv")
 (depends
  (ocaml
   (>= 4.07))
  (dune
   (>= 2.7))
  (toml
   (>= 6.0))
  (bisect_ppx
   (and
    :with-test
    (>= "2.5")))
  (cconv
   (>= 0.5))))
