;;; needspace.el --- AUCTeX style for `needspace.sty' (v1.3e)  -*- lexical-binding: t; -*-

;; Copyright (C) 2025 Free Software Foundation, Inc.

;; Author: Arash Esbati <arash@gnu.org>
;; Maintainer: auctex-devel@gnu.org
;; Created: 2025-03-18
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

;; This file adds support for `needspace.sty' (v1.3e) from 2025-03-13.
;; `needspace.sty' is part of TeXLive.

;;; Code:

(require 'tex)

;; Silence the compiler:
(declare-function font-latex-add-keywords "font-latex" (keywords class))

(TeX-add-style-hook
 "needspace"
 (lambda ()

   (TeX-add-symbols
    '("needspace"  (TeX-arg-length "Space"))
    '("Needspace"  (TeX-arg-length "Space"))
    '("Needspace*" (TeX-arg-length "Space")))

   ;; Fontification
   (when (and (featurep 'font-latex)
              (eq TeX-install-font-lock 'font-latex-setup))
     (font-latex-add-keywords '(("needspace" "{")
                                ("Needspace" "*{"))
                              'function)))
 TeX-dialect)

(defvar LaTeX-needspace-package-options nil
  "Prompt for package options for the needspace package.")

;;; needspace.el ends here
