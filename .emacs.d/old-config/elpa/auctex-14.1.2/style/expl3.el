;;; expl3.el --- AUCTeX style for `expl3.sty'  -*- lexical-binding: t; -*-

;; Copyright (C) 2015--2025 Free Software Foundation, Inc.

;; Author: Tassilo Horn <tsdh@gnu.org>
;; Maintainer: auctex-devel@gnu.org
;; Created: 2015-02-22
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

;; This file adds support for `expl3.sty'.  The macros in this style are
;; taken from `interface3.pdf'.

;;; Code:

;; Silence the compiler:
(declare-function font-latex-add-keywords "font-latex" (keywords class))
(defvar font-latex-match-simple-include-list)

(require 'tex)
(require 'latex)

(defvar LaTeX-expl3-syntax-table
  (let ((st (copy-syntax-table LaTeX-mode-syntax-table)))
    ;; Make _ and : word chars
    (modify-syntax-entry ?\_ "w" st)
    (modify-syntax-entry ?\: "w" st)
    st))

(defun TeX-arg-expl3-macro (_optional &optional prompt definition no-param)
  "Read and insert an expl3 macro.
OPTIONAL is ignored.  PROMPT replaces the standard one only when asking
for the macro name.  If DEFINITION is non-nil, add the chosen macro to
the list of defined macros.  Ask also for macro parameters if NO-PARAM
is non-nil."
  (let* ((macro (completing-read
                 (TeX-argument-prompt nil prompt
                                      (concat "Function: " TeX-esc)
                                      t)
                 (TeX-symbol-list)))
         (params (progn
                   (when (string-empty-p macro)
                     (error "%s" "Function name missing"))
                   (if no-param
                       ""
                     (TeX-read-string
                      (TeX-argument-prompt t nil "Parameter")))))
         (TeX-arg-opening-brace "")
         (TeX-arg-closing-brace ""))
    (when (and definition (not (string-empty-p macro)))
      (TeX-add-symbols macro))
    (just-one-space)
    (TeX-argument-insert macro nil TeX-esc)
    (just-one-space)
    (unless (string-empty-p params)
      (TeX-argument-insert params nil)
      (just-one-space))))

(defun TeX-arg-expl3-define-macro (optional &optional prompt no-param)
  "Define a expl3 macro.
Pass OPTIONAL, PROMPT and NO-PARAM to `TeX-arg-expl3-macro', which see."
  (TeX-arg-expl3-macro optional prompt t no-param))

(defvar LaTeX-expl3-newmac-regexp
  (let ((macs '("cs_set"            "cs_set_nopar"
                "cs_set_protected"  "cs_set_protected_nopar"
                "cs_gset"           "cs_gset_nopar"
                "cs_gset_protected" "cs_gset_protected_nopar"
                "cs_new"            "cs_new_nopar"
                "cs_new_protected"  "cs_new_protected_nopar"
                "cs_generate_from_arg_count"))
        (toks "[a-zA-Z:@_]+"))
    `(,(concat (regexp-quote TeX-esc)
               (regexp-opt macs)
               ":[Ncenpx]+"
               "[ \t]*"
               (regexp-quote TeX-esc)
               "\\(" toks "\\)")
      1 TeX-auto-symbol))
  "Matches new macros defined with various expl3 functions.")

(TeX-add-style-hook
 "expl3"
 (lambda ()
   (set-syntax-table LaTeX-expl3-syntax-table)
   (when (and (featurep 'font-latex)
              (eq TeX-install-font-lock 'font-latex-setup))
     ;; Fontify _ and : as part of macros.
     (add-to-list 'font-latex-match-simple-include-list "_" t)
     (add-to-list 'font-latex-match-simple-include-list ":" t))

   ;; Add expl3 macros to the parser.
   (TeX-auto-add-regexp LaTeX-expl3-newmac-regexp)

   (TeX-add-symbols

    ;; 2.1 Using the LaTeX3 modules
    '("ExplSyntaxOn" 0)
    '("ExplSyntaxOff" 0)

    '("ProvidesExplClass"
      (TeX-arg-file-name-sans-extension "Class name")
      TeX-arg-date TeX-arg-version "Description")

    '("ProvidesExplFile"
      (TeX-arg-file-name "File name")
      TeX-arg-date TeX-arg-version "Description")

    '("ProvidesExplPackage"
      (TeX-arg-file-name-sans-extension "Package name")
      TeX-arg-date TeX-arg-version "Description")

    '("GetIdInfo"
      (TeX-arg-literal " $Id: ")
      (TeX-arg-free "SVN info field")
      (TeX-arg-literal " $ ") "Description")

    '("ExplFileName" 0)
    '("ExplFileDate" 0)
    '("ExplFileVersion" 0)
    '("ExplFileDescription" 0)

    ;; 4.1 No operation functions
    "prg_do_nothing:" "scan_stop:"

    ;; 4.2 Grouping material
    "group_begin:" "group_end:"
    "group_insert_after:N"
    "group_show_list:" "group_log_list:"

    ;; 4.3.2 Defining new functions using parameter text
    '("cs_new:Npn" TeX-arg-expl3-define-macro t)
    '("cs_new:cpn" TeX-arg-expl3-define-macro t)
    '("cs_new:Npe" TeX-arg-expl3-define-macro t)
    '("cs_new:cpe" TeX-arg-expl3-define-macro t)
    '("cs_new:Npx" TeX-arg-expl3-define-macro t)
    '("cs_new:cpx" TeX-arg-expl3-define-macro t)
    '("cs_new_nopar:Npn" TeX-arg-expl3-define-macro t)
    '("cs_new_nopar:cpn" TeX-arg-expl3-define-macro t)
    '("cs_new_nopar:Npe" TeX-arg-expl3-define-macro t)
    '("cs_new_nopar:cpe" TeX-arg-expl3-define-macro t)
    '("cs_new_nopar:Npx" TeX-arg-expl3-define-macro t)
    '("cs_new_nopar:cpx" TeX-arg-expl3-define-macro t)
    '("cs_new_protected:Npn" TeX-arg-expl3-define-macro t)
    '("cs_new_protected:cpn" TeX-arg-expl3-define-macro t)
    '("cs_new_protected:Npe" TeX-arg-expl3-define-macro t)
    '("cs_new_protected:cpe" TeX-arg-expl3-define-macro t)
    '("cs_new_protected:Npx" TeX-arg-expl3-define-macro t)
    '("cs_new_protected:cpx" TeX-arg-expl3-define-macro t)
    '("cs_new_protected_nopar:Npn" TeX-arg-expl3-define-macro t)
    '("cs_new_protected_nopar:cpn" TeX-arg-expl3-define-macro t)
    '("cs_new_protected_nopar:Npe" TeX-arg-expl3-define-macro t)
    '("cs_new_protected_nopar:cpe" TeX-arg-expl3-define-macro t)
    '("cs_new_protected_nopar:Npx" TeX-arg-expl3-define-macro t)
    '("cs_new_protected_nopar:cpx" TeX-arg-expl3-define-macro t)

    '("cs_set:Npn" TeX-arg-expl3-define-macro t)
    '("cs_set:cpn" TeX-arg-expl3-define-macro t)
    '("cs_set:Npe" TeX-arg-expl3-define-macro t)
    '("cs_set:cpe" TeX-arg-expl3-define-macro t)
    '("cs_set:Npx" TeX-arg-expl3-define-macro t)
    '("cs_set:cpx" TeX-arg-expl3-define-macro t)
    '("cs_set_nopar:Npn" TeX-arg-expl3-define-macro t)
    '("cs_set_nopar:cpn" TeX-arg-expl3-define-macro t)
    '("cs_set_nopar:Npe" TeX-arg-expl3-define-macro t)
    '("cs_set_nopar:cpe" TeX-arg-expl3-define-macro t)
    '("cs_set_nopar:Npx" TeX-arg-expl3-define-macro t)
    '("cs_set_nopar:cpx" TeX-arg-expl3-define-macro t)
    '("cs_set_protected:Npn" TeX-arg-expl3-define-macro t)
    '("cs_set_protected:cpn" TeX-arg-expl3-define-macro t)
    '("cs_set_protected:Npe" TeX-arg-expl3-define-macro t)
    '("cs_set_protected:cpe" TeX-arg-expl3-define-macro t)
    '("cs_set_protected:Npx" TeX-arg-expl3-define-macro t)
    '("cs_set_protected:cpx" TeX-arg-expl3-define-macro t)
    '("cs_set_protected_nopar:Npn" TeX-arg-expl3-define-macro t)
    '("cs_set_protected_nopar:cpn" TeX-arg-expl3-define-macro t)
    '("cs_set_protected_nopar:Npe" TeX-arg-expl3-define-macro t)
    '("cs_set_protected_nopar:cpe" TeX-arg-expl3-define-macro t)
    '("cs_set_protected_nopar:Npx" TeX-arg-expl3-define-macro t)
    '("cs_set_protected_nopar:cpx" TeX-arg-expl3-define-macro t)

    '("cs_gset:Npn" TeX-arg-expl3-define-macro t)
    '("cs_gset:cpn" TeX-arg-expl3-define-macro t)
    '("cs_gset:Npe" TeX-arg-expl3-define-macro t)
    '("cs_gset:cpe" TeX-arg-expl3-define-macro t)
    '("cs_gset:Npx" TeX-arg-expl3-define-macro t)
    '("cs_gset:cpx" TeX-arg-expl3-define-macro t)
    '("cs_gset_nopar:Npn" TeX-arg-expl3-define-macro t)
    '("cs_gset_nopar:cpn" TeX-arg-expl3-define-macro t)
    '("cs_gset_nopar:Npe" TeX-arg-expl3-define-macro t)
    '("cs_gset_nopar:cpe" TeX-arg-expl3-define-macro t)
    '("cs_gset_nopar:Npx" TeX-arg-expl3-define-macro t)
    '("cs_gset_nopar:cpx" TeX-arg-expl3-define-macro t)
    '("cs_gset_protected:Npn" TeX-arg-expl3-define-macro t)
    '("cs_gset_protected:cpn" TeX-arg-expl3-define-macro t)
    '("cs_gset_protected:Npe" TeX-arg-expl3-define-macro t)
    '("cs_gset_protected:cpe" TeX-arg-expl3-define-macro t)
    '("cs_gset_protected:Npx" TeX-arg-expl3-define-macro t)
    '("cs_gset_protected:cpx" TeX-arg-expl3-define-macro t)
    '("cs_gset_protected_nopar:Npn" TeX-arg-expl3-define-macro t)
    '("cs_gset_protected_nopar:cpn" TeX-arg-expl3-define-macro t)
    '("cs_gset_protected_nopar:Npe" TeX-arg-expl3-define-macro t)
    '("cs_gset_protected_nopar:cpe" TeX-arg-expl3-define-macro t)
    '("cs_gset_protected_nopar:Npx" TeX-arg-expl3-define-macro t)
    '("cs_gset_protected_nopar:cpx" TeX-arg-expl3-define-macro t)

    ;; 4.3.3 Defining new functions using the signature
    '("cs_new:Nn" (TeX-arg-expl3-define-macro nil t) t)
    '("cs_new:cn" (TeX-arg-expl3-define-macro nil t) t)
    '("cs_new:Ne" (TeX-arg-expl3-define-macro nil t) t)
    '("cs_new:ce" (TeX-arg-expl3-define-macro nil t) t)
    '("cs_new_nopar:Nn" (TeX-arg-expl3-define-macro nil t) t)
    '("cs_new_nopar:cn" (TeX-arg-expl3-define-macro nil t) t)
    '("cs_new_nopar:Ne" (TeX-arg-expl3-define-macro nil t) t)
    '("cs_new_nopar:ce" (TeX-arg-expl3-define-macro nil t) t)
    '("cs_new_protected:Nn" (TeX-arg-expl3-define-macro nil t) t)
    '("cs_new_protected:cn" (TeX-arg-expl3-define-macro nil t) t)
    '("cs_new_protected:Ne" (TeX-arg-expl3-define-macro nil t) t)
    '("cs_new_protected:ce" (TeX-arg-expl3-define-macro nil t) t)
    '("cs_new_protected_nopar:Nn" (TeX-arg-expl3-define-macro nil t) t)
    '("cs_new_protected_nopar:cn" (TeX-arg-expl3-define-macro nil t) t)
    '("cs_new_protected_nopar:Ne" (TeX-arg-expl3-define-macro nil t) t)
    '("cs_new_protected_nopar:ce" (TeX-arg-expl3-define-macro nil t) t)

    '("cs_set:Nn" (TeX-arg-expl3-define-macro nil t) t)
    '("cs_set:cn" (TeX-arg-expl3-define-macro nil t) t)
    '("cs_set:Ne" (TeX-arg-expl3-define-macro nil t) t)
    '("cs_set:ce" (TeX-arg-expl3-define-macro nil t) t)
    '("cs_set_nopar:Nn" (TeX-arg-expl3-define-macro nil t) t)
    '("cs_set_nopar:cn" (TeX-arg-expl3-define-macro nil t) t)
    '("cs_set_nopar:Ne" (TeX-arg-expl3-define-macro nil t) t)
    '("cs_set_nopar:ce" (TeX-arg-expl3-define-macro nil t) t)
    '("cs_set_protected:Nn" (TeX-arg-expl3-define-macro nil t) t)
    '("cs_set_protected:cn" (TeX-arg-expl3-define-macro nil t) t)
    '("cs_set_protected:Ne" (TeX-arg-expl3-define-macro nil t) t)
    '("cs_set_protected:ce" (TeX-arg-expl3-define-macro nil t) t)
    '("cs_set_protected_nopar:Nn" (TeX-arg-expl3-define-macro nil t) t)
    '("cs_set_protected_nopar:cn" (TeX-arg-expl3-define-macro nil t) t)
    '("cs_set_protected_nopar:Ne" (TeX-arg-expl3-define-macro nil t) t)
    '("cs_set_protected_nopar:ce" (TeX-arg-expl3-define-macro nil t) t)

    '("cs_gset:Nn" (TeX-arg-expl3-define-macro nil t) t)
    '("cs_gset:cn" (TeX-arg-expl3-define-macro nil t) t)
    '("cs_gset:Ne" (TeX-arg-expl3-define-macro nil t) t)
    '("cs_gset:ce" (TeX-arg-expl3-define-macro nil t) t)
    '("cs_gset_nopar:Nn" (TeX-arg-expl3-define-macro nil t) t)
    '("cs_gset_nopar:cn" (TeX-arg-expl3-define-macro nil t) t)
    '("cs_gset_nopar:Ne" (TeX-arg-expl3-define-macro nil t) t)
    '("cs_gset_nopar:ce" (TeX-arg-expl3-define-macro nil t) t)
    '("cs_gset_protected:Nn" (TeX-arg-expl3-define-macro nil t) t)
    '("cs_gset_protected:cn" (TeX-arg-expl3-define-macro nil t) t)
    '("cs_gset_protected:Ne" (TeX-arg-expl3-define-macro nil t) t)
    '("cs_gset_protected:ce" (TeX-arg-expl3-define-macro nil t) t)
    '("cs_gset_protected_nopar:Nn" (TeX-arg-expl3-define-macro nil t) t)
    '("cs_gset_protected_nopar:cn" (TeX-arg-expl3-define-macro nil t) t)
    '("cs_gset_protected_nopar:Ne" (TeX-arg-expl3-define-macro nil t) t)
    '("cs_gset_protected_nopar:ce" (TeX-arg-expl3-define-macro nil t) t)

    '("cs_generate_from_arg_count:NNnn"
      TeX-arg-space (TeX-arg-free TeX-arg-define-macro)
      TeX-arg-space (TeX-arg-free TeX-arg-macro)
      TeX-arg-space "Number of arguments" t)

    ;; 4.3.4 Copying control sequences
    '("cs_new_eq:NN"
      TeX-arg-space (TeX-arg-free TeX-arg-define-macro)
      TeX-arg-space (TeX-arg-free TeX-arg-macro))
    '("cs_new_eq:Nc"
      TeX-arg-space (TeX-arg-free TeX-arg-define-macro)
      TeX-arg-space (TeX-arg-free TeX-arg-macro))
    '("cs_new_eq:NN"
      TeX-arg-space (TeX-arg-free TeX-arg-define-macro)
      TeX-arg-space (TeX-arg-free TeX-arg-macro))
    '("cs_new_eq:cN"
      TeX-arg-space (TeX-arg-free TeX-arg-define-macro)
      TeX-arg-space (TeX-arg-free TeX-arg-macro))
    '("cs_new_eq:cc"
      TeX-arg-space (TeX-arg-free TeX-arg-define-macro)
      TeX-arg-space (TeX-arg-free TeX-arg-macro))

    '("cs_set_eq:NN"
      TeX-arg-space (TeX-arg-free TeX-arg-define-macro)
      TeX-arg-space (TeX-arg-free TeX-arg-macro))
    '("cs_set_eq:Nc"
      TeX-arg-space (TeX-arg-free TeX-arg-define-macro)
      TeX-arg-space (TeX-arg-free TeX-arg-macro))
    '("cs_set_eq:cN"
      TeX-arg-space (TeX-arg-free TeX-arg-define-macro)
      TeX-arg-space (TeX-arg-free TeX-arg-macro))
    '("cs_set_eq:cc"
      TeX-arg-space (TeX-arg-free TeX-arg-define-macro)
      TeX-arg-space (TeX-arg-free TeX-arg-macro))
    '("cs_gset_eq:NN"
      TeX-arg-space (TeX-arg-free TeX-arg-define-macro)
      TeX-arg-space (TeX-arg-free TeX-arg-macro))
    '("cs_gset_eq:Nc"
      TeX-arg-space (TeX-arg-free TeX-arg-define-macro)
      TeX-arg-space (TeX-arg-free TeX-arg-macro))
    '("cs_gset_eq:cN"
      TeX-arg-space (TeX-arg-free TeX-arg-define-macro)
      TeX-arg-space (TeX-arg-free TeX-arg-macro))
    '("cs_gset_eq:cc"
      TeX-arg-space (TeX-arg-free TeX-arg-define-macro)
      TeX-arg-space (TeX-arg-free TeX-arg-macro))

    ;; 4.3.5 Deleting control sequences
    '("cs_undefine:N"
      TeX-arg-space (TeX-arg-free TeX-arg-macro))
    '("cs_undefine:c"
      TeX-arg-space (TeX-arg-free TeX-arg-macro))

    ;; 4.3.6 Showing control sequences
    '("cs_meaning:N"
      TeX-arg-space (TeX-arg-free TeX-arg-macro))
    '("cs_meaning:c"
      TeX-arg-space (TeX-arg-free TeX-arg-macro))
    '("cs_show:N"
      TeX-arg-space (TeX-arg-free TeX-arg-macro))
    '("cs_show:c"
      TeX-arg-space (TeX-arg-free TeX-arg-macro))
    '("cs_log:N"
      TeX-arg-space (TeX-arg-free TeX-arg-macro))
    '("cs_log:c"
      TeX-arg-space (TeX-arg-free TeX-arg-macro))

    ;; 4.3.7 Converting to and from control sequences
    '("use:c" t)
    '("cs_if_exist_use:N"
      TeX-arg-space (TeX-arg-free TeX-arg-macro))
    '("cs_if_exist_use:c"
      TeX-arg-space (TeX-arg-free TeX-arg-macro))
    '("cs_if_exist_use:NTF"
      TeX-arg-space (TeX-arg-free TeX-arg-macro)
      TeX-arg-space t TeX-arg-space nil)
    '("cs_if_exist_use:cTF"
      TeX-arg-space (TeX-arg-free TeX-arg-macro)
      TeX-arg-space t TeX-arg-space nil)

    '("cs:w"
      TeX-arg-space
      TeX-arg-set-exit-mark
      (TeX-arg-literal " \\cs_end:"))

    '("cs_to_str:N"
      TeX-arg-space (TeX-arg-free TeX-arg-macro))

    ;; 4.4 Analysing control sequences
    '("cs_split_function:N"
      TeX-arg-space (TeX-arg-free TeX-arg-macro))
    '("cs_prefix_spec:N"
      TeX-arg-space (TeX-arg-free TeX-arg-macro))
    '("cs_parameter_spec:N"
      TeX-arg-space (TeX-arg-free TeX-arg-macro))
    '("cs_replacement_spec:N"
      TeX-arg-space (TeX-arg-free TeX-arg-macro))
    '("cs_replacement_spec:c"
      TeX-arg-space (TeX-arg-free TeX-arg-macro))

    ;; 4.5 Using or removing tokens and arguments
    '("use:n" TeX-arg-space t)
    '("use:nn"
      TeX-arg-space  t (TeX-arg-literal " {}"))
    '("use:nnn"
      TeX-arg-space  t (TeX-arg-literal " {} {}"))
    '("use:nnnn"
      TeX-arg-space  t  (TeX-arg-literal " {} {} {}"))

    ;; \use_i:nn et al. missing here.

    '("use_i_ii:nnn"
      TeX-arg-space  t (TeX-arg-literal " {} {}"))
    '("use_ii_i:nn"
      TeX-arg-space  t (TeX-arg-literal " {}"))

    '("use_none:n"
      TeX-arg-space  t)
    '("use_none:nn"
      TeX-arg-space  t (TeX-arg-literal " {}"))
    '("use_none:nnn"
      TeX-arg-space  t (TeX-arg-literal " {} {}"))
    '("use_none:nnnn"
      TeX-arg-space  t (TeX-arg-literal " {} {} {}"))
    '("use_none:nnnnn"
      TeX-arg-space  t (TeX-arg-literal " {} {} {} {}"))
    '("use_none:nnnnnn"
      TeX-arg-space  t (TeX-arg-literal " {} {} {} {} {}"))
    '("use_none:nnnnnnn"
      TeX-arg-space  t (TeX-arg-literal " {} {} {} {} {} {}"))
    '("use_none:nnnnnnnn"
      TeX-arg-space  t (TeX-arg-literal " {} {} {} {} {} {} {}"))
    '("use_none:nnnnnnnnn"
      TeX-arg-space  t (TeX-arg-literal " {} {} {} {} {} {} {} {}"))

    '("use_:e"
      TeX-arg-space  t)

    ;; 4.5.1 Selecting tokens from delimited arguments
    '("use_none_delimit_by_q_nil:w"
      TeX-arg-space
      TeX-arg-set-exit-mark
      (TeX-arg-literal " \\q_nil"))
    '("use_none_delimit_by_q_stop:w"
      TeX-arg-space
      TeX-arg-set-exit-mark
      (TeX-arg-literal " \\q_stop"))
    '("use_none_delimit_by_q_recursion_stop:w"
      TeX-arg-space
      TeX-arg-set-exit-mark
      (TeX-arg-literal " \\q_recursion_stop"))

    '("use_i_delimit_by_q_nil:nw"
      TeX-arg-space t (TeX-arg-literal " \\q_nil"))
    '("use_i_delimit_by_q_stop:nw"
      TeX-arg-space t (TeX-arg-literal " \\q_stop"))
    '("use_i_delimit_by_q_recursion_stop:nw"
      TeX-arg-space t (TeX-arg-literal " \\q_recursion_stop"))

    ;; 4.6.1 Tests on control sequences
    '("cs_if_eq_p:NN"
      TeX-arg-space (TeX-arg-free TeX-arg-macro)
      TeX-arg-space (TeX-arg-free TeX-arg-macro))
    '("cs_if_eq_p:Nc"
      TeX-arg-space (TeX-arg-free TeX-arg-macro)
      TeX-arg-space (TeX-arg-free TeX-arg-macro))
    '("cs_if_eq_p:cN"
      TeX-arg-space (TeX-arg-free TeX-arg-macro)
      TeX-arg-space (TeX-arg-free TeX-arg-macro))
    '("cs_if_eq_p:cc"
      TeX-arg-space (TeX-arg-free TeX-arg-macro)
      TeX-arg-space (TeX-arg-free TeX-arg-macro))

    '("cs_if_eq:NNTF"
      TeX-arg-space (TeX-arg-free TeX-arg-macro)
      TeX-arg-space (TeX-arg-free TeX-arg-macro)
      TeX-arg-space t (TeX-arg-literal " {}"))
    '("cs_if_eq:NcTF"
      TeX-arg-space (TeX-arg-free TeX-arg-macro)
      TeX-arg-space (TeX-arg-free TeX-arg-macro)
      TeX-arg-space t (TeX-arg-literal " {}"))
    '("cs_if_eq:cNTF"
      TeX-arg-space (TeX-arg-free TeX-arg-macro)
      TeX-arg-space (TeX-arg-free TeX-arg-macro)
      TeX-arg-space t (TeX-arg-literal " {}"))
    '("cs_if_eq:ccTF"
      TeX-arg-space (TeX-arg-free TeX-arg-macro)
      TeX-arg-space (TeX-arg-free TeX-arg-macro)
      TeX-arg-space t (TeX-arg-literal " {}"))

    '("cs_if_exist_p:N"
      TeX-arg-space (TeX-arg-free TeX-arg-macro))
    '("cs_if_exist_p:c"
      TeX-arg-space (TeX-arg-free TeX-arg-macro))
    '("cs_if_exist:NTF"
      TeX-arg-space (TeX-arg-free TeX-arg-macro)
      TeX-arg-space t (TeX-arg-literal " {}"))
    '("cs_if_exist:cTF"
      TeX-arg-space (TeX-arg-free TeX-arg-macro)
      TeX-arg-space t (TeX-arg-literal " {}"))

    '("cs_if_free_p:N"
      TeX-arg-space (TeX-arg-free TeX-arg-macro))
    '("cs_if_free_p:c"
      TeX-arg-space (TeX-arg-free TeX-arg-macro))
    '("cs_if_free:NTF"
      TeX-arg-space (TeX-arg-free TeX-arg-macro)
      TeX-arg-space t (TeX-arg-literal " {}"))
    '("cs_if_free:cTF"
      TeX-arg-space (TeX-arg-free TeX-arg-macro)
      TeX-arg-space t (TeX-arg-literal " {}"))

    ;; 4.6.2 Primitive conditionals
    '("if_true:"
      TeX-arg-space TeX-arg-set-exit-mark
      (TeX-arg-literal " \\else: \\fi:"))
    '("if_false:"
      TeX-arg-space TeX-arg-set-exit-mark
      (TeX-arg-literal " \\else: \\fi:"))

    "else:" "fi:" "reverse_if:N"

    '("if_meaning:w"
      TeX-arg-space TeX-arg-set-exit-mark
      (TeX-arg-literal " \\else: \\fi:"))

    '("if:w"
      TeX-arg-space TeX-arg-set-exit-mark
      (TeX-arg-literal " \\else: \\fi:"))
    '("if_charcode:w"
      TeX-arg-space TeX-arg-set-exit-mark
      (TeX-arg-literal " \\else: \\fi:"))
    '("if_catcode:w"
      TeX-arg-space TeX-arg-set-exit-mark
      (TeX-arg-literal " \\else: \\fi:"))

    '("if_cs_exist:N"
      TeX-arg-space TeX-arg-set-exit-mark
      (TeX-arg-free TeX-arg-macro)
      (TeX-arg-literal " \\else: \\fi:"))
    '("if_cs_exist:w"
      TeX-arg-space TeX-arg-set-exit-mark
      (TeX-arg-literal " \\cs_end: \\else: \\fi:"))

    '("if_mode_horizontal:"
      TeX-arg-space TeX-arg-set-exit-mark
      (TeX-arg-literal " \\else: \\fi:"))
    '("if_mode_vertical:"
      TeX-arg-space TeX-arg-set-exit-mark
      (TeX-arg-literal " \\else: \\fi:"))
    '("if_mode_math:"
      TeX-arg-space TeX-arg-set-exit-mark
      (TeX-arg-literal " \\else: \\fi:"))
    '("if_mode_inner:"
      TeX-arg-space TeX-arg-set-exit-mark
      (TeX-arg-literal " \\else: \\fi:"))

    ;; 4.7 Starting a paragraph
    '("mode_leave_vertical:")

    ;; 4.8 Debugging support
    '("debug_on:n"
      TeX-arg-space
      (TeX-arg-completing-read-multiple ("check-declarations" "check-expressions"
                                         "deprecation" "log-functions" "all")
                                        "Debug option(s)"))
    '("debug_off:n"
      TeX-arg-space
      (TeX-arg-completing-read-multiple ("check-declarations" "check-expressions"
                                         "deprecation" "log-functions" "all")
                                        "Debug option(s)"))

    '("debug_suspend:"
      TeX-arg-space TeX-arg-set-exit-mark
      (TeX-arg-literal " \\debug_resume:"))
    "debug_resume:"

    ;; 5.2 Methods for defining variants
    )

   ;; Fontification
   (when (and (featurep 'font-latex)
              (eq TeX-install-font-lock 'font-latex-setup))
     (font-latex-add-keywords '(("ExplSyntaxOn"  "")
                                ("ExplSyntaxOff" ""))
                              'warning)
     (font-latex-add-keywords '(("ProvidesExplClass"   "{{{{")
                                ("ProvidesExplFile"    "{{{{")
                                ("ProvidesExplPackage" "{{{{")
                                ("GetIdInfo"           "")

                                ("cs_new:Npn" "\\")
                                ("cs_new:cpn" "\\")
                                ("cs_new:Npe" "\\")
                                ("cs_new:cpe" "\\")
                                ("cs_new:Npx" "\\")
                                ("cs_new:cpx" "\\")
                                ("cs_new_nopar:Npn" "\\")
                                ("cs_new_nopar:cpn" "\\")
                                ("cs_new_nopar:Npe" "\\")
                                ("cs_new_nopar:cpe" "\\")
                                ("cs_new_nopar:Npx" "\\")
                                ("cs_new_nopar:cpx" "\\")
                                ("cs_new_protected:Npn" "\\")
                                ("cs_new_protected:cpn" "\\")
                                ("cs_new_protected:Npe" "\\")
                                ("cs_new_protected:cpe" "\\")
                                ("cs_new_protected:Npx" "\\")
                                ("cs_new_protected:cpx" "\\")
                                ("cs_new_protected_nopar:Npn" "\\")
                                ("cs_new_protected_nopar:cpn" "\\")
                                ("cs_new_protected_nopar:Npe" "\\")
                                ("cs_new_protected_nopar:cpe" "\\")
                                ("cs_new_protected_nopar:Npx" "\\")
                                ("cs_new_protected_nopar:cpx" "\\")

                                ("cs_set:Npn" "\\")
                                ("cs_set:cpn" "\\")
                                ("cs_set:Npe" "\\")
                                ("cs_set:cpe" "\\")
                                ("cs_set:Npx" "\\")
                                ("cs_set:cpx" "\\")
                                ("cs_set_nopar:Npn" "\\")
                                ("cs_set_nopar:cpn" "\\")
                                ("cs_set_nopar:Npe" "\\")
                                ("cs_set_nopar:cpe" "\\")
                                ("cs_set_nopar:Npx" "\\")
                                ("cs_set_nopar:cpx" "\\")
                                ("cs_set_protected:Npn" "\\")
                                ("cs_set_protected:cpn" "\\")
                                ("cs_set_protected:Npe" "\\")
                                ("cs_set_protected:cpe" "\\")
                                ("cs_set_protected:Npx" "\\")
                                ("cs_set_protected:cpx" "\\")
                                ("cs_set_protected_nopar:Npn" "\\")
                                ("cs_set_protected_nopar:cpn" "\\")
                                ("cs_set_protected_nopar:Npe" "\\")
                                ("cs_set_protected_nopar:cpe" "\\")
                                ("cs_set_protected_nopar:Npx" "\\")
                                ("cs_set_protected_nopar:cpx" "\\")

                                ("cs_gset:Npn" "\\")
                                ("cs_gset:cpn" "\\")
                                ("cs_gset:Npe" "\\")
                                ("cs_gset:cpe" "\\")
                                ("cs_gset:Npx" "\\")
                                ("cs_gset:cpx" "\\")
                                ("cs_gset_nopar:Npn" "\\")
                                ("cs_gset_nopar:cpn" "\\")
                                ("cs_gset_nopar:Npe" "\\")
                                ("cs_gset_nopar:cpe" "\\")
                                ("cs_gset_nopar:Npx" "\\")
                                ("cs_gset_nopar:cpx" "\\")
                                ("cs_gset_protected:Npn" "\\")
                                ("cs_gset_protected:cpn" "\\")
                                ("cs_gset_protected:Npe" "\\")
                                ("cs_gset_protected:cpe" "\\")
                                ("cs_gset_protected:Npx" "\\")
                                ("cs_gset_protected:cpx" "\\")
                                ("cs_gset_protected_nopar:Npn" "\\")
                                ("cs_gset_protected_nopar:cpn" "\\")
                                ("cs_gset_protected_nopar:Npe" "\\")
                                ("cs_gset_protected_nopar:cpe" "\\")
                                ("cs_gset_protected_nopar:Npx" "\\")
                                ("cs_gset_protected_nopar:cpx" "\\")

                                ("cs_new:Nn" "\\")
                                ("cs_new:cn" "\\")
                                ("cs_new:Ne" "\\")
                                ("cs_new:ce" "\\")
                                ("cs_new_nopar:Nn" "\\")
                                ("cs_new_nopar:cn" "\\")
                                ("cs_new_nopar:Ne" "\\")
                                ("cs_new_nopar:ce" "\\")
                                ("cs_new_protected:Nn" "\\")
                                ("cs_new_protected:cn" "\\")
                                ("cs_new_protected:Ne" "\\")
                                ("cs_new_protected:ce" "\\")
                                ("cs_new_protected_nopar:Nn" "\\")
                                ("cs_new_protected_nopar:cn" "\\")
                                ("cs_new_protected_nopar:Ne" "\\")
                                ("cs_new_protected_nopar:ce" "\\")

                                ("cs_set:Nn" "\\")
                                ("cs_set:cn" "\\")
                                ("cs_set:Ne" "\\")
                                ("cs_set:ce" "\\")
                                ("cs_set_nopar:Nn" "\\")
                                ("cs_set_nopar:cn" "\\")
                                ("cs_set_nopar:Ne" "\\")
                                ("cs_set_nopar:ce" "\\")
                                ("cs_set_protected:Nn" "\\")
                                ("cs_set_protected:cn" "\\")
                                ("cs_set_protected:Ne" "\\")
                                ("cs_set_protected:ce" "\\")
                                ("cs_set_protected_nopar:Nn" "\\")
                                ("cs_set_protected_nopar:cn" "\\")
                                ("cs_set_protected_nopar:Ne" "\\")
                                ("cs_set_protected_nopar:ce" "\\")

                                ("cs_gset:Nn" "\\")
                                ("cs_gset:cn" "\\")
                                ("cs_gset:Ne" "\\")
                                ("cs_gset:ce" "\\")
                                ("cs_gset_nopar:Nn" "\\")
                                ("cs_gset_nopar:cn" "\\")
                                ("cs_gset_nopar:Ne" "\\")
                                ("cs_gset_nopar:ce" "\\")
                                ("cs_gset_protected:Nn" "\\")
                                ("cs_gset_protected:cn" "\\")
                                ("cs_gset_protected:Ne" "\\")
                                ("cs_gset_protected:ce" "\\")
                                ("cs_gset_protected_nopar:Nn" "\\")
                                ("cs_gset_protected_nopar:cn" "\\")
                                ("cs_gset_protected_nopar:Ne" "\\")
                                ("cs_gset_protected_nopar:ce" "\\")

                                ("cs_generate_from_arg_count:NNnn" "|{\\")

                                ("cs_new_eq:NN" "\\\\")
                                ("cs_new_eq:Nc" "\\\\")
                                ("cs_new_eq:cN" "\\\\")
                                ("cs_new_eq:cc" "\\\\")
                                ("cs_set_eq:NN" "\\\\")
                                ("cs_set_eq:Nc" "\\\\")
                                ("cs_set_eq:cN" "\\\\")
                                ("cs_set_eq:cc" "\\\\")
                                ("cs_gset_eq:NN" "\\\\")
                                ("cs_gset_eq:Nc" "\\\\")
                                ("cs_gset_eq:cN" "\\\\")
                                ("cs_gset_eq:cc" "\\\\")

                                ("cs_undefine:N" "\\")
                                ("cs_undefine:c" "\\"))
                              'function)
     ;; Also tell font-lock to update its internals
     (setq font-lock-major-mode nil)
     (font-lock-set-defaults)))
 TeX-dialect)

(defvar LaTeX-expl3-package-options-list
  '(("check-declarations" ("true" "false"))
    ("log-functions" ("true" "false"))
    ("enable-debug" ("true" "false"))
    ("backend" ("dvips"   "dvipdfmx"
                "dvisvgm" "luatex"
                "pdftex"  "xetex"))
    ("suppress-backend-headers" ("true" "false")))
  "Package options for the expl3 package.")

(defun LaTeX-expl3-package-options ()
  "Prompt for package options for the expl3 package."
  (TeX-read-key-val t LaTeX-expl3-package-options-list))

;;; expl3.el ends here
