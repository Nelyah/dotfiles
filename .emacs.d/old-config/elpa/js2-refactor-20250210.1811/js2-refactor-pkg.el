;; -*- no-byte-compile: t; lexical-binding: nil -*-
(define-package "js2-refactor" "20250210.1811"
  "The beginnings of a JavaScript refactoring library in emacs."
  '((js2-mode         "20101228")
    (s                "1.9.0")
    (multiple-cursors "1.0.0")
    (dash             "1.0.0")
    (s                "1.0.0")
    (yasnippet        "0.9.0.1"))
  :url "https://github.com/js-emacs/js2-refactor.el"
  :commit "e1177c728ae52a5e67157fb18ee1409d8e95386a"
  :revdesc "e1177c728ae5"
  :keywords '("conveniences")
  :authors '(("Magnar Sveen" . "magnars@gmail.com")
             ("Nicolas Petton" . "nicolas@petton.fr"))
  :maintainers '(("Magnar Sveen" . "magnars@gmail.com")
                 ("Nicolas Petton" . "nicolas@petton.fr")))
