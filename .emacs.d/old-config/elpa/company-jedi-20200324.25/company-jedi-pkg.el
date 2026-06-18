;; -*- no-byte-compile: t; lexical-binding: nil -*-
(define-package "company-jedi" "20200324.25"
  "Company-mode completion back-end for Python JEDI."
  '((emacs     "24")
    (cl-lib    "0.5")
    (company   "0.8.11")
    (jedi-core "0.2.7"))
  :url "https://github.com/emacsorphanage/company-jedi"
  :commit "a5a9f7ddf2770bbfad9e39a275053923fe82a200"
  :revdesc "a5a9f7ddf277"
  :authors '(("Boy" . "boyw165@gmail.com"))
  :maintainers '(("Neil Okamoto" . "neil.okamoto+melpa@gmail.com")))
