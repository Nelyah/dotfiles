;;; wrapstuff.el --- AUCTeX style for `wrapstuff.sty' v0.3  -*- lexical-binding: t; -*-

;; Copyright (C) 2025 Free Software Foundation, Inc.

;; Author: Arash Esbati <arash@gnu.org>
;; Maintainer: auctex-devel@gnu.org
;; Created: 2025-07-08
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

;; This file adds support for `wrapstuff.sty' v0.3 from 2022-08-05.
;; `wrapstuff.sty' is part of TeXLive.

;;; Code:

(require 'tex)
(require 'latex)

;; Silence the compiler:
(declare-function font-latex-add-keywords "font-latex" (keywords class))

(defvar LaTeX-wrapstuff-key-val-options
  '(("top")
    ("lines")
    ("l")
    ("r")
    ("c")
    ("i")
    ("o")
    ("ratio")
    ("column" ("true" "false" "par"))
    ("type" ("figure" "table")))
  "Key=value options for wrapstuff macro and environment.")

(defun LaTeX-wrapstuff-key-val-options ()
  "Return an updated list of key=vals for wrapstuff macro and environment."
  (let ((keys '("width"
                "height"
                "linewidth"
                "leftsep"
                "rightsep"
                "hsep"
                "abovesep"
                "belowsep"
                "vsep"
                "hoffset"
                "voffset"))
        (len (mapcar (lambda (x)
                       (concat TeX-esc (car x)))
                     (LaTeX-length-list)))
        result)
    (append
     (dolist (key keys result)
       (push (list key len) result))
     LaTeX-wrapstuff-key-val-options)))

(TeX-add-style-hook
 "wrapstuff"
 (lambda ()
   (LaTeX-add-environments
    '("wrapstuff" LaTeX-env-args
      [TeX-arg-key-val (LaTeX-wrapstuff-key-val-options)]))

   (TeX-add-symbols
    '("wrapstuffset"
      (TeX-arg-key-val (LaTeX-wrapstuff-key-val-options)))
    "wrapstuffclear")

   ;; Fontification
   (when (and (featurep 'font-latex)
              (eq TeX-install-font-lock 'font-latex-setup))
     (font-latex-add-keywords '(("wrapstuffset" "{"))
                              'function)
     (font-latex-add-keywords '("wrapstuffclear")
                              'function-noarg)))
 TeX-dialect)

(defvar LaTeX-wrapstuff-package-options nil
  "Package options for the wrapstuff package.")

;;; wrapstuff.el ends here
