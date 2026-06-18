;; -*- no-byte-compile: t; lexical-binding: nil -*-
(define-package "ivy-bibtex" "20210927.1205"
  "A bibliography manager based on Ivy."
  '((bibtex-completion "1.0.0")
    (ivy               "0.13.0")
    (cl-lib            "0.5"))
  :url "https://github.com/tmalsburg/helm-bibtex"
  :commit "bb47f355b0da8518aa3fb516019120c14c8747c9"
  :revdesc "bb47f355b0da"
  :authors '(("Justin Burkett" . "justin@burkett.cc"))
  :maintainers '(("Titus von der Malsburg" . "malsburg@posteo.de")))
