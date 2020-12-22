(lang dune 1.10)

(using menhir 1.0)

(license LGPL3)

(authors "Julien Sagot" "Emmanuel Surleau" "mackwic" "Andrew Rudenko"
  "orbifx" "c-cube")

(maintainers "OCamlPro <contact@ocamlpro.com>")

(source
 (github ocaml-toml/To.ml))

(homepage https://github.com/ocaml-toml/To.ml/)

(documentation https://ocaml-toml.github.io/To.ml/)

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
   (>= 1.10))
  (menhir :build)
  (ounit :with-test)
  (bisect :with-test)
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
   (>= 1.10))
  (toml
   (>= 6.0))
  (cconv
   (>= 0.5))))
