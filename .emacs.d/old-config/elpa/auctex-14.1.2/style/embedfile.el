;;; embedfile.el --- AUCTeX style for `embedfile.sty' (v2.12)  -*- lexical-binding: t; -*-

;; Copyright (C) 2025 Free Software Foundation, Inc.

;; Author: Arash Esbati <arash@gnu.org>
;; Maintainer: auctex-devel@gnu.org
;; Created: 2025-03-14
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

;; This file adds support for `embedfile.sty' (v2.12) from 2023-01-12.
;; `embedfile.sty' is part of TeXLive.

;;; Code:

(require 'tex)
(require 'latex)

;; Silence the compiler:
(declare-function font-latex-add-keywords "font-latex" (keywords class))

(defvar LaTeX-embedfile-key-val-options
  '(("filespec")
    ("ucfilespec")
    ("filesystem")
    ;; This can only be a small excerpt:
    ("mimetype" ("application/javascript"
                 "application/msword"
                 "application/pdf"
                 "application/postscript"
                 "application/vnd.ms-excel"
                 "application/vnd.ms-powerpoint"
                 "application/vnd.openxmlformats-officedocument.presentationml.presentation"
                 "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
                 "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
                 "application/zip"
                 "audio/mpeg"
                 "audio/ogg"
                 "image/jpeg"
                 "image/png"
                 "image/tiff"
                 "text/csv"
                 "text/plain"
                 "video/H264"
                 "video/mp4"))
    ("desc")
    ("stringmethod" ("psd" "escape"))
    ("id"))
  "Key=value options for embedfile macros.")

(TeX-add-style-hook
 "embedfile"
 (lambda ()

   (TeX-add-symbols
    '("embedfile"
      [TeX-arg-key-val LaTeX-embedfile-key-val-options nil nil ?\s]
      (lambda (optional)
        (let ((file (file-relative-name
                     (read-file-name
                      (TeX-argument-prompt optional nil "File to embed"))
                     (TeX-master-directory))))
          (TeX-argument-insert file optional))))

    '("embedfilesetup"
      (TeX-arg-key-val (lambda ()
                         (append
                          '(("view" ("details" "tile" "hidden"))
                            ("initialfile"))
                          LaTeX-embedfile-key-val-options))))

    '("embedfilefield"
      "Key"
      (TeX-arg-key-val (("type" ("text" "date" "number" "file" "desc"
                                 "moddate" "size"))
                        ("title")
                        ("visible" ("true" "false"))
                        ("edit" ("true" "false")))
                       nil nil ?\s))

    "embedfilefinish"

    '("embedfilesort"
      (TeX-arg-completing-read ("ascending" "descending")
                               "Sort order"))

    '("embedfileifobjectexists"
      "Id" (TeX-arg-completing-read ("EmbeddedFile" "Filespec") "Type")
      t nil)

    '("embedfilegetobject"
      "Id" (TeX-arg-completing-read ("EmbeddedFile" "Filespec") "Type")))

   ;; Fontification
   (when (and (featurep 'font-latex)
              (eq TeX-install-font-lock 'font-latex-setup))
     (font-latex-add-keywords '(("embedfile"               "[{")
                                ("embedfilesetup"          "{")
                                ("embedfilefinish"         "")
                                ("embedfilefield"          "{{")
                                ("embedfilesort"           "{")
                                ;; Don't fontify the last 2 args which
                                ;; will contain code:
                                ("embedfileifobjectexists" "{{")
                                ("embedfilegetobject"      "{{"))
                              'function)))
 TeX-dialect)

;;; embedfile.el ends here
