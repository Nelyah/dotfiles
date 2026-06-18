;;; ltx-talk.el --- AUCTeX style for `ltx-talk.cls' (v0.3.8)  -*- lexical-binding: t; -*-

;; Copyright (C) 2025--2026 Free Software Foundation, Inc.

;; Author: Arash Esbati <arash@gnu.org>
;; Maintainer: auctex-devel@gnu.org
;; Created: 2025-09-22
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

;; This file adds support for `ltx-talk.sty' (v0.3.8) from 2026-01-12.
;; `ltx-talk.sty' is part of TeXLive.

;;; Code:

(require 'tex)
(require 'latex)

;; Silence the compiler:
(declare-function font-latex-add-keywords "font-latex" (keywords class))

(defun TeX-arg-ltx-talk-overlay-spec (optional &optional prompt)
  "Prompt for overlay specification.
If OPTIONAL is non-nil, insert the specification only if non-empty and
enclosed in \"<>\".  PROMPT replaces the standard one."
  (TeX-arg-string optional (or prompt "Overlay") nil nil nil "<" ">")
  (indent-according-to-mode))

(defun LaTeX-item-ltx-talk (&optional macro)
  "Insert a new item with an optional overlay argument.
You can turn off the prompt for the overlay argument by setting
`LaTeX-ltx-talk-item-overlay-flag' to nil.

Optional MACRO can be a string, for example, \"bibitem\"."
  (TeX-insert-macro (or macro "item")))

(TeX-add-style-hook
 "ltx-talk"
 (lambda ()

   ;; Run style hook for various packages loaded by ltx-talk
   (TeX-run-style-hooks "geometry" "amsmath" "hyperref" "xcolor" "graphicx")

   ;; New symbols
   (TeX-add-symbols
    ;; 6.2 Components of a frame: The optional [<options>] arg seems to
    ;; be unused, to skip it for now:
    '("frametitle" [TeX-arg-ltx-talk-overlay-spec] "Title")
    '("framesubtitle" [TeX-arg-ltx-talk-overlay-spec] "Subtitle")

    ;; 7.1 The \pause command
    '("pause" [TeX-arg-ltx-talk-overlay-spec])

    ;; 7.3 Commands with overlay specifications
    '("onslide"   [TeX-arg-ltx-talk-overlay-spec])
    '("only"      [TeX-arg-ltx-talk-overlay-spec] "Text")
    '("uncover"   [TeX-arg-ltx-talk-overlay-spec] "Text")
    '("visible"   [TeX-arg-ltx-talk-overlay-spec] "Text")
    '("invisible" [TeX-arg-ltx-talk-overlay-spec] "Text")
    '("alt"       [TeX-arg-ltx-talk-overlay-spec]
      "Default text" "Alternative text")
    '("temporal"  [TeX-arg-ltx-talk-overlay-spec]
      "Before slide text" "Default text" "After slide text")

    ;; Command provided by LaTeX core or other packages:
    '("label" [TeX-arg-ltx-talk-overlay-spec] TeX-arg-define-label)

    ;; \color<overlay>{<name>} or \color<overlay>[<model>]{<color spec>}
    '("color"
      [TeX-arg-ltx-talk-overlay-spec]
      [TeX-arg-completing-read-multiple (LaTeX-xcolor-color-models)
                                        "Color model"
                                        nil nil "/" "/"]
      (TeX-arg-conditional (LaTeX-xcolor-cmd-requires-spec-p 'col)
          (TeX-arg-xcolor)
        ((TeX-arg-completing-read (LaTeX-xcolor-definecolor-list)
                                  "Color name"))))

    ;; \textcolor<overlay>{<name>}{<text>} or
    ;; \textcolor<overlay>[<model>]{<color spec>}{<text>}
    '("textcolor"
      [TeX-arg-ltx-talk-overlay-spec]
      [TeX-arg-completing-read-multiple (LaTeX-xcolor-color-models)
                                        "Color model"
                                        nil nil "/" "/"]
      (TeX-arg-conditional (LaTeX-xcolor-cmd-requires-spec-p 'col)
          (TeX-arg-xcolor)
        ((TeX-arg-completing-read (LaTeX-xcolor-definecolor-list)
                                  "Color name")))
      "Text")

    ;; \mathcolor<overlay>{<name>}{<math>} or
    ;; \mathcolor<overlay>[<model>]{<color spec>}{<math>}
    '("mathcolor"
      [TeX-arg-ltx-talk-overlay-spec]
      [TeX-arg-completing-read-multiple (LaTeX-xcolor-color-models)
                                        "Color model"
                                        nil nil "/" "/"]
      (TeX-arg-conditional (LaTeX-xcolor-cmd-requires-spec-p 'col)
          (TeX-arg-xcolor)
        ((TeX-arg-completing-read (LaTeX-xcolor-definecolor-list)
                                  "Color name")))
      "Math")

    ;; \includegraphics<overlay>[<options>]{<file>}
    '("includegraphics"
      [TeX-arg-ltx-talk-overlay-spec]
      [TeX-arg-key-val (LaTeX-graphicx-key-val-options) nil nil ?\s]
      LaTeX-arg-includegraphics)

    ;; 7.6.2 Action specifications
    '("action" [TeX-arg-ltx-talk-overlay-spec "Action spec"] "Text")

    ;; 8.1 Adding a title frame
    '("maketitle" [TeX-arg-completing-read-multiple ("element-order"
                                                     "frame-style"
                                                     "horizontal-alignment"
                                                     "vertical-alignment")
                                                    "Settings"])

    '("author"
      [TeX-arg-key-val (("short-author")) nil nil ?\s]
      LaTeX-arg-author)
    '("date"
      [TeX-arg-key-val (("short-date")) nil nil ?\s]
      TeX-arg-date)
    '("institute"
      [TeX-arg-key-val (("short-institute")) nil nil ?\s]
      "Institute")
    '("subtitle"
      [TeX-arg-key-val (("short-subtitle")) nil nil ?\s]
      "Subtitle")
    '("title"
      [TeX-arg-key-val (("short-title")) nil nil ?\s]
      t)

    ;; 9.1 Itemizations, enumerations and descriptions
    '("item"
      (TeX-arg-conditional LaTeX-ltx-talk-item-overlay-flag
          ([TeX-arg-ltx-talk-overlay-spec "Action spec"])
        ())
      (TeX-arg-conditional (or TeX-arg-item-label-p
                               (string= (LaTeX-current-environment)
                                        "description"))
          (["Item label"])
        ())
      TeX-arg-space)

    ;; 9.2 Highlighting
    '("alert" [TeX-arg-ltx-talk-overlay-spec] "Text"))

   (LaTeX-add-environments
    ;; 6.1 The frame environment: The optional [<options>] arg seems to
    ;; be unused, to skip it for now:
    '("frame" LaTeX-env-args
      [TeX-arg-ltx-talk-overlay-spec]
      (TeX-arg-conditional (or (LaTeX-provided-class-options-member
                                "ltx-talk" "frame-title-arg")
                               (LaTeX-provided-class-options-member
                                "ltx-talk" "frame-title-arg=true"))
          ("Title")
        ()))
    '("frame*" LaTeX-env-args
      [TeX-arg-ltx-talk-overlay-spec]
      (TeX-arg-conditional (or (LaTeX-provided-class-options-member
                                "ltx-talk" "frame-title-arg")
                               (LaTeX-provided-class-options-member
                                "ltx-talk" "frame-title-arg=true"))
          ("Title")
        ()))

    ;; 7.5 Dynamically changing text or images
    '("overlayarea" LaTeX-env-args
      (TeX-arg-length "Area width") (TeX-arg-length "Area height"))
    '("overprint" LaTeX-env-args
      [TeX-arg-length "Area width"])

    ;; 7.6.2 Action specifications
    '("actionenv" LaTeX-env-args
      [TeX-arg-ltx-talk-overlay-spec "Action spec"])

    ;; 9.1 Itemizations, enumerations and descriptions
    '("description" LaTeX-env-item-args
      [TeX-arg-key-val (("action-spec") ("<>"))])
    '("enumerate" LaTeX-env-item-args
      [TeX-arg-key-val (("action-spec") ("<>"))])
    '("itemize" LaTeX-env-item-args
      [TeX-arg-key-val (("action-spec") ("<>"))])

    ;; 9.2 Highlighting
    '("alertenv" LaTeX-env-args
      [TeX-arg-ltx-talk-overlay-spec])

    ;; 9.5 Splitting a frame into multiple columns
    `("columns" LaTeX-env-args
      [TeX-arg-ltx-talk-overlay-spec "Action spec"]
      [TeX-arg-key-val (lambda ()
                         (append
                          `(("width" ,(mapcar (lambda (x) (concat TeX-esc (car x)))
                                              (LaTeX-length-list))))
                          '(("vertical-alignment" ("bottom" "center" "top")))))])

    '("column" LaTeX-env-args
      [TeX-arg-ltx-talk-overlay-spec "Action spec"]
      ["Placement"]
      TeX-arg-length) )

   ;; 7.4 Environments with overlay specifications
   (let ((envs '("onlyenv" "invisibleenv" "uncoverenv" "visibleenv"))
         result)
     (dolist (env envs)
       (push `(,env LaTeX-env-args [TeX-arg-ltx-talk-overlay-spec])
             result))
     (apply #'LaTeX-add-environments result))

   ;; Switch the default:
   (setq LaTeX-default-document-environment "frame")

   ;; Additions to `LaTeX-item-list':
   (let ((envs '("description" "enumerate" "itemize")))
     (dolist (env envs)
       (add-to-list 'LaTeX-item-list `(,env . LaTeX-item-ltx-talk))))

   ;; Commands which should stay in their own lines:
   (LaTeX-paragraph-commands-add-locally '("frametitle"
                                           "framesubtitle"
                                           "pause"
                                           "onslide"
                                           "only"
                                           "uncover"
                                           "visible"
                                           "invisible"
                                           "alt"
                                           "temporal"
                                           "action"
                                           "alert"))

   ;; Fontification
   (when (and (featurep 'font-latex)
              (eq TeX-install-font-lock 'font-latex-setup))
     (font-latex-add-keywords '(("author"        "[{")
                                ("date"          "[{")
                                ("institute"     "[{")
                                ("subtitle"      "[{")
                                ("title"         "[{")
                                ("frametitle"    "<[{")
                                ("framesubtitle" "<[{"))
                              'slide-title)
     (font-latex-add-keywords '(("item"      "<[")
                                ("bibitem"   "<[{")
                                ("only"      "<{")
                                ("uncover"   "<{")
                                ("visible"   "<{")
                                ("invisible" "<{")
                                ("alt"       "<{{")
                                ("temporal"  "<{{{")
                                ("action"    "<{")
                                ("alert"     "<{"))
                              'textual)
     (font-latex-add-keywords '(("textbf" "<{")
                                ("textsc" "<{")
                                ("textup" "<{"))
                              'bold-command)
     (font-latex-add-keywords '(("emph"   "<{")
                                ("textit" "<{")
                                ("textsl" "<{"))
                              'italic-command)
     (font-latex-add-keywords '(("textmd"     "<{")
                                ("textrm"     "<{")
                                ("textsf"     "<{")
                                ("texttt"     "<{")
                                ("textnormal" "<{")
                                ("textcolor"  "<[{"))
                              'type-command)
     (font-latex-add-keywords '(("color"      "<[{"))
                              'type-declaration)
     (font-latex-add-keywords '(("includegraphics" "*<[[{")
                                ("label"       "<{")
                                ("hyperlink"   "<{{<")
                                ("hypertarget" "<{{"))
                              'reference)
     (font-latex-add-keywords '(("pause"     "[")
                                ("maketitle" "["))
                              'function)))
 TeX-dialect)

(defvar LaTeX-ltx-talk-class-options-list
  '(("aspect-ratio")
    ("mode" ("handout" "projector"))
    ("handout")
    ("frame-title-arg" ("true" "false")))
  "Alist of class options for the ltx-talk class.")

(defun LaTeX-ltx-talk-class-options ()
  "Prompt for the class options for the ltx-talk class."
  (TeX-read-key-val t LaTeX-ltx-talk-class-options-list))

;;; ltx-talk.el ends here
