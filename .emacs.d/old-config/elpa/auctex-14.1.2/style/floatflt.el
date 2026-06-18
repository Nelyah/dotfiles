;;; floatflt.el --- AUCTeX style for `floatflt.sty' v1.31  -*- lexical-binding: t; -*-

;; Copyright (C) 2025 Free Software Foundation, Inc.

;; Author: Arash Esbati <arash@gnu.org>
;; Maintainer: auctex-devel@gnu.org
;; Created: 2025-10-08
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

;; This file adds support for `floatflt.sty' v1.31 from 1998-06-05.
;; `floatflt.sty' is part of TeXLive.

;;; Code:

(require 'tex)
(require 'latex)

;; Silence the compiler:
(declare-function font-latex-add-keywords "font-latex" (keywords class))

(TeX-add-style-hook
 "floatflt"
 (lambda ()

   (LaTeX-add-environments
    ;; \begin{floatingfigure}[option]{width}
    '("floatingfigure" LaTeX-env-args
      [TeX-arg-completing-read ("r" "l" "p" "v") "Placement"]
      (TeX-arg-length "Width"))

    ;; \begin{floatingtable}[option]{width}
    '("floatingtable" LaTeX-env-args
      [TeX-arg-completing-read ("r" "l" "p" "v") "Placement"]
      (TeX-arg-length "Width")))

   ;; 3.1 How to Avoid the List Problem
   (TeX-add-symbols
    '("fltitem"  [TeX-arg-length "Extra vertical space"] t)
    '("fltditem" [TeX-arg-length "Extra vertical space"] "Label" t))

   ;; Indentation
   (unless (string-search "fltd?item" LaTeX-item-regexp)
     (setq-local LaTeX-item-regexp
                 (concat LaTeX-item-regexp "\\|fltd?item\\b")))

   ;; Tell RefTeX: `reftex-label-alist-builtin' has an entry for
   ;; "floatingfigure".  We only add an entry for "floatingtable" when
   ;; it's missing.  Emacs 31 supports floatflt, floatfig is removed:
   (when (and (boundp 'reftex-label-alist-builtin)
              (not (assq 'floatflt reftex-label-alist-builtin))
              (fboundp 'reftex-add-label-environments))
     (reftex-add-label-environments
      '(("floatingtable" ?t nil nil caption))))

   ;; Fontification
   (when (and (featurep 'font-latex)
              (eq TeX-install-font-lock 'font-latex-setup))
     (font-latex-add-keywords '(("fltitem"  "[{")
                                ("fltditem" "[{{"))
                              'textual)))
 TeX-dialect)

(defvar LaTeX-floatflt-package-options '("rflt" "lflt" "vflt")
  "Package options for the floatflt package.")

;;; floatflt.el ends here
