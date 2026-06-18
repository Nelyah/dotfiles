;;; figureversions.el --- AUCTeX style for `figureversions.sty' v1.0.1  -*- lexical-binding: t; -*-

;; Copyright (C) 2025 Free Software Foundation, Inc.

;; Author: Arash Esbati <arash@gnu.org>
;; Maintainer: auctex-devel@gnu.org
;; Created: 2025-04-06
;; Keywords: tex

;; This file is part of AUCTeX.

;; AUCTeX is free software; you can redistribute it and/or modify it
;; under the terms of the GNU General Public License as published by the
;; Free Software Foundation; either version 3, or (at your option) any
;; later version.

;; AUCTeX is distributed in the hope that it will be useful, but WITHOUT
;; ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
;; FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
;; for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:

;; This file adds support for `figureversions.sty' v1.0.1 from
;; 2025-04-29.  `figureversions.sty' is part of TeXLive.

;;; Code:

(require 'tex)
(require 'latex)

;; Silence the compiler:
(declare-function font-latex-add-keywords "font-latex" (keywords class))

(TeX-add-style-hook
 "figureversions"
 (lambda ()
   (TeX-add-symbols
    ;; 2.1 High-level document commands
    '("lnfigures"     -1)  ; style: lining figures
    '("txfigures"     -1)  ; style: text figures (osf)
    '("liningfigures" "Text")
    '("textfigures"   "Text")

    '("prfigures"           -1)  ; alignment: proportional figures
    '("tbfigures"           -1)  ; alignment: tabular figures
    '("proportionalfigures" "Text")
    '("tabularfigures"      "Text")

    ;; Math versions
    '("boldmath"         -1)  ; math weight
    '("unboldmath"       -1)
    '("tabularmath"      -1)  ; math figure alignment
    '("proportionalmath" -1)

    ;; Figure versions
    '("figureversion"
      (TeX-arg-completing-read-multiple ("text"         "osf"
                                         "lining"       "lf"
                                         "tabular"      "tab"
                                         "proportional" "prop")
                                        "Style, alignment"))

    ;; 2.2 Low-level document commands
    '("fontfigurestyle"
      (TeX-arg-completing-read ("text" "lining")
                               "Style"))
    '("fontfigurealignment"
      (TeX-arg-completing-read ("tabular" "proportional")
                               "Alignment"))
    '("fontbasefamily" "Font family")

    '("mathweight"
      (TeX-arg-completing-read ("bold" "normal")
                               "Math weight"))
    '("mathfigurealignment"
      (TeX-arg-completing-read ("tabular" "proportional")
                               "Math figure alignment")))

   ;; 2.3 Code-level interface
   ;; Add the macros only in `docTeX-mode':
   (when (derived-mode-p 'docTeX-mode)
     (TeX-run-style-hooks "expl3")
     (TeX-add-symbols
      '("figureversions_new_figurestyle:nnn"
        TeX-arg-space "Name"
        TeX-arg-space "Proportional suffixes"
        TeX-arg-space "Tabular suffixes")
      '("figureversions_new_figureversion:nn"
        TeX-arg-space "Option"
        TeX-arg-space t)))

   ;; Fontification
   (when (and (featurep 'font-latex)
              (eq TeX-install-font-lock 'font-latex-setup))
     (font-latex-add-keywords '(("liningfigures"       "{")
                                ("textfigures"         "{")
                                ("proportionalfigures" "{")
                                ("tabularfigures"      "{"))
                              'type-command)
     (font-latex-add-keywords '("lnfigures" "txfigures"
                                "prfigures" "tbfigures")
                              'type-declaration)
     (font-latex-add-keywords '(("figureversion"       "{"))
                              'variable)))
 TeX-dialect)

(defvar LaTeX-figureversions-package-options nil
  "Package options for the figureversions package.")

;;; figureversions.el ends here
