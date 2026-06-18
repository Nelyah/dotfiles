;;; iftex.el --- AUCTeX style for `iftex.sty' version 1.0g  -*- lexical-binding: t; -*-

;; Copyright (C) 2022--2025 Free Software Foundation, Inc.

;; Author: Arash Esbati <arash@gnu.org>
;; Maintainer: auctex-devel@gnu.org
;; Created: 2022-04-17
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

;; This file adds support for `iftex.sty' v1.0g from 2024/12/12.
;; `iftex.sty' is part of TeXlive.

;;; Code:

(require 'tex)

;; Silence the compiler:
(declare-function font-latex-add-keywords "font-latex" (keywords class))

(TeX-add-style-hook
 "iftex"
 (lambda ()

   (TeX-add-symbols
    '("ifetex"
      TeX-arg-set-exit-mark
      (TeX-arg-literal "\\else\\fi"))
    '("ifeTeX"
      TeX-arg-set-exit-mark
      (TeX-arg-literal "\\else\\fi"))

    '("ifpdftex"
      TeX-arg-set-exit-mark
      (TeX-arg-literal "\\else\\fi"))
    '("ifPDFTeX"
      TeX-arg-set-exit-mark
      (TeX-arg-literal "\\else\\fi"))

    '("ifxetex"
      TeX-arg-set-exit-mark
      (TeX-arg-literal "\\else\\fi"))
    '("ifXeTeX"
      TeX-arg-set-exit-mark
      (TeX-arg-literal "\\else\\fi"))

    '("ifluatex"
      TeX-arg-set-exit-mark
      (TeX-arg-literal "\\else\\fi"))
    '("ifLuaTeX"
      TeX-arg-set-exit-mark
      (TeX-arg-literal "\\else\\fi"))

    '("ifluahbtex"
      TeX-arg-set-exit-mark
      (TeX-arg-literal "\\else\\fi"))
    '("ifLuaHBTeX"
      TeX-arg-set-exit-mark
      (TeX-arg-literal "\\else\\fi"))

    '("ifluametatex"
      TeX-arg-set-exit-mark
      (TeX-arg-literal "\\else\\fi"))
    '("ifLuaMetaTeX"
      TeX-arg-set-exit-mark
      (TeX-arg-literal "\\else\\fi"))

    '("ifptex"
      TeX-arg-set-exit-mark
      (TeX-arg-literal "\\else\\fi"))
    '("ifpTeX"
      TeX-arg-set-exit-mark
      (TeX-arg-literal "\\else\\fi"))

    '("ifuptex"
      TeX-arg-set-exit-mark
      (TeX-arg-literal "\\else\\fi"))
    '("ifupTeX"
      TeX-arg-set-exit-mark
      (TeX-arg-literal "\\else\\fi"))

    '("ifptexng"
      TeX-arg-set-exit-mark
      (TeX-arg-literal "\\else\\fi"))
    '("ifpTeXng"
      TeX-arg-set-exit-mark
      (TeX-arg-literal "\\else\\fi"))

    '("ifvtex"
      TeX-arg-set-exit-mark
      (TeX-arg-literal "\\else\\fi"))
    '("ifVTeX"
      TeX-arg-set-exit-mark
      (TeX-arg-literal "\\else\\fi"))

    '("ifalephtex"
      TeX-arg-set-exit-mark
      (TeX-arg-literal "\\else\\fi"))
    '("ifAlephTeX"
      TeX-arg-set-exit-mark
      (TeX-arg-literal "\\else\\fi"))

    '("iftutex"
      TeX-arg-set-exit-mark
      (TeX-arg-literal "\\else\\fi"))
    '("ifTUTeX"
      TeX-arg-set-exit-mark
      (TeX-arg-literal "\\else\\fi"))

    '("iftexpadtex"
      TeX-arg-set-exit-mark
      (TeX-arg-literal "\\else\\fi"))
    '("ifTexpadTeX"
      TeX-arg-set-exit-mark
      (TeX-arg-literal "\\else\\fi"))

    '("iftex"
      TeX-arg-set-exit-mark
      (TeX-arg-literal "\\else\\fi"))
    '("ifTeX"
      TeX-arg-set-exit-mark
      (TeX-arg-literal "\\else\\fi"))

    '("ifhint"
      TeX-arg-set-exit-mark
      (TeX-arg-literal "\\else\\fi"))
    '("ifHINT"
      TeX-arg-set-exit-mark
      (TeX-arg-literal "\\else\\fi"))

    '("ifprote"
      TeX-arg-set-exit-mark
      (TeX-arg-literal "\\else\\fi"))
    '("ifProte"
      TeX-arg-set-exit-mark
      (TeX-arg-literal "\\else\\fi"))

    "RequireeTeX"
    "RequirePDFTeX"
    "RequireXeTeX"
    "RequireLuaTeX"
    "RequireLuaHBTeX"
    "RequireLuaMetaTeX"
    "RequirepTeX"
    "RequireupTeX"
    "RequirepTeXng"
    "RequireVTeX"
    "RequireAlephTeX"
    "RequireTUTeX"
    "RequireTexpadTeX"
    "RequireHINT"
    "RequireProte")

   ;; This package is used to make it possible to compile a document
   ;; with different TeX engines.  By setting `TeX-check-engine-list'
   ;; to nil we ignore engine restrictions posed by other packages.
   (TeX-check-engine-add-engines nil)

   ;; Fontification:
   (when (and (featurep 'font-latex)
              (eq TeX-install-font-lock 'font-latex-setup))
     (font-latex-add-keywords '(("RequireeTeX"       "")
                                ("RequirePDFTeX"     "")
                                ("RequireXeTeX"      "")
                                ("RequireLuaTeX"     "")
                                ("RequireLuaHBTeX"   "")
                                ("RequireLuaMetaTeX" "")
                                ("RequirepTeX"       "")
                                ("RequireupTeX"      "")
                                ("RequirepTeXng"     "")
                                ("RequireVTeX"       "")
                                ("RequireAlephTeX"   "")
                                ("RequireTUTeX"      "")
                                ("RequireTexpadTeX"  "")
                                ("RequireHINT"       "")
                                ("RequireProte"      ""))
                              'function)))
 TeX-dialect)

(defvar LaTeX-iftex-package-options nil
  "Package options for the iftex package.")

;;; iftex.el ends here
