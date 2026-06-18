;;; fontaxes.el --- AUCTeX style for `fontaxes.sty' v2.0.1  -*- lexical-binding: t; -*-

;; Copyright (C) 2014--2025 Free Software Foundation, Inc.

;; Author: Arash Esbati <arash@gnu.org>
;; Maintainer: auctex-devel@gnu.org
;; Created: 2014-10-12
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

;; This file adds support for `fontaxes.sty' v2.0.1 from 2025-05-24.
;; `fontaxes.sty' is deprecated in favor of `figureversions.sty'.  This
;; style reflects this change and loads `figureversions.el', adding the
;; remaining compatibility macros to AUCTeX.

;;; Code:

(require 'tex)

(TeX-add-style-hook
 "fontaxes"
 (lambda ()

   (TeX-run-style-hooks "figureversions")

   (TeX-add-symbols
    '("fontprimaryshape"   t)
    '("fontsecondaryshape" t))

   (when (derived-mode-p 'docTeX-mode)
     (TeX-add-symbols
      '("fa@naming@exception" 3))))
 TeX-dialect)

(defvar LaTeX-fontaxes-package-options nil
  "Package options for the fontaxes package.")

;;; fontaxes.el ends here
