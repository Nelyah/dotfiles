;; -*- lexical-binding: t; -*-

;;;; ————————————————————————————————————————————————————————————
;;;; Package bootstrap
;;;; ————————————————————————————————————————————————————————————

(require 'package)
(setq package-archives
      '(("gnu"    . "https://elpa.gnu.org/packages/")
        ("nongnu" . "https://elpa.nongnu.org/nongnu/")
        ("melpa"  . "https://melpa.org/packages/")))
(package-initialize)

;; Explicitly install any missing packages (refresh only when needed)
(defvar my/packages
  '(evil evil-collection evil-surround evil-commentary
    general which-key
    vertico orderless consult marginalia embark embark-consult
    mixed-pitch org-modern olivetti corfu cape
    org-ql affe doom-themes))

(let ((missing (seq-filter (lambda (p) (not (package-installed-p p))) my/packages)))
  (when missing
    (package-refresh-contents)
    (dolist (pkg missing)
      (package-install pkg))))

(setq use-package-always-ensure t)

;; Must be set before evil or evil-collection loads
(setq evil-want-keybinding nil)

;; Keep customize output separate
(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
(when (file-exists-p custom-file)
  (load custom-file))

;; macOS GUI Emacs doesn't inherit shell PATH — add Homebrew
(add-to-list 'exec-path "/opt/homebrew/bin")
(setenv "PATH" (concat "/opt/homebrew/bin:" (getenv "PATH")))

;;;; ————————————————————————————————————————————————————————————
;;;; Sane defaults
;;;; ————————————————————————————————————————————————————————————

(setq inhibit-startup-message t
      initial-scratch-message nil
      initial-buffer-choice "~/cloud/utils/org/inbox.org"
      ring-bell-function 'ignore
      use-short-answers t
      delete-by-moving-to-trash t
      default-directory "~/cloud/utils/org/")

;; Readline bindings in minibuffer (C-u/C-w are stolen by evil)
(define-key minibuffer-local-map (kbd "C-u") (lambda () (interactive) (kill-line 0)))
(define-key minibuffer-local-map (kbd "C-w") #'backward-kill-word)

;; Backups — keep them out of the way
(let ((backup-dir (expand-file-name "~/.local/share/emacs/backups/")))
  (ignore-errors (make-directory backup-dir t))
  (setq backup-directory-alist `(("." . ,backup-dir))
        backup-by-copying t
        delete-old-versions t
        kept-new-versions 6
        kept-old-versions 2
        version-control t))

;; Auto-save files alongside backups
(let ((auto-save-dir (expand-file-name "~/.local/share/emacs/auto-save/")))
  (ignore-errors (make-directory auto-save-dir t))
  (setq auto-save-file-name-transforms `((".*" ,auto-save-dir t))))

;; Auto-refresh buffers
(global-auto-revert-mode 1)
(setq global-auto-revert-non-file-buffers t
      auto-revert-verbose nil)

;; Smooth scrolling (macOS trackpad)
(setq scroll-conservatively 101)
(pixel-scroll-precision-mode 1)

;; No blinking cursor
(blink-cursor-mode -1)

;; Dired
(setq dired-dwim-target t)

;;;; ————————————————————————————————————————————————————————————
;;;; macOS
;;;; ————————————————————————————————————————————————————————————

(when (eq system-type 'darwin)
  (setq mac-option-modifier 'meta
        mac-command-modifier 'super
        mac-right-option-modifier 'none))

;;;; ————————————————————————————————————————————————————————————
;;;; Fonts
;;;; ————————————————————————————————————————————————————————————

(defvar my/fixed-pitch-font "Hack Nerd Font Mono")
(defvar my/variable-pitch-font "Charter")
(defvar my/font-size 140)

(set-face-attribute 'default nil
                    :family my/fixed-pitch-font
                    :height my/font-size)
(set-face-attribute 'fixed-pitch nil
                    :family my/fixed-pitch-font
                    :height 1.0)
(set-face-attribute 'variable-pitch nil
                    :family my/variable-pitch-font
                    :height 1.2)

;;;; ————————————————————————————————————————————————————————————
;;;; Theme — doom-one (Atom One Dark)
;;;; ————————————————————————————————————————————————————————————

(use-package doom-themes
  :config
  (setq doom-themes-enable-bold t
        doom-themes-enable-italic t)
  (load-theme 'doom-one t)
  (doom-themes-org-config))

;; Heading sizes (variable-pitch)
(custom-set-faces
 '(org-level-1 ((t (:inherit variable-pitch :height 1.4))))
 '(org-level-2 ((t (:inherit variable-pitch :height 1.25))))
 '(org-level-3 ((t (:inherit variable-pitch :height 1.15))))
 '(org-level-4 ((t (:inherit variable-pitch :height 1.1))))
 '(org-headline-done ((t (:strike-through t)))))

(with-eval-after-load 'org
  (set-face-attribute 'org-quote nil
                      :inherit 'variable-pitch
                      :background "#23272e")

  (defface my/org-quote-bar
    '((t :inherit org-quote :foreground "#61afef"))
    "Face for the quote bar character.")

  (defvar-local my/quote-bar-overlays nil))

;;;; ————————————————————————————————————————————————————————————
;;;; Evil mode
;;;; ————————————————————————————————————————————————————————————

;; Vim emulation
(use-package evil
  :demand t
  :init
  (setq evil-want-integration t
        evil-want-C-u-scroll t
        evil-want-Y-yank-to-eol t
        evil-undo-system 'undo-redo
        evil-search-module 'evil-search
        evil-split-window-below t
        evil-vsplit-window-right t)
  :config
  (evil-mode 1)
  (evil-global-set-key 'motion "j" 'evil-next-visual-line)
  (evil-global-set-key 'motion "k" 'evil-previous-visual-line)
  (evil-global-set-key 'motion "H" (lambda () (interactive) (evil-backward-char 5)))
  (evil-global-set-key 'motion "J" (lambda () (interactive) (evil-next-visual-line 5)))
  (evil-global-set-key 'motion "K" (lambda () (interactive) (evil-previous-visual-line 5)))
  (evil-global-set-key 'motion "L" (lambda () (interactive) (evil-forward-char 5)))
  (evil-global-set-key 'normal (kbd "C-j") 'evil-join)
  (evil-global-set-key 'visual (kbd "C-j") 'evil-join)

  ;; Org-agenda evil bindings (evil-collection has no org-agenda module)
  (evil-set-initial-state 'org-agenda-mode 'normal)
  (with-eval-after-load 'org-agenda
    (evil-define-key 'normal org-agenda-mode-map
      "j"   'org-agenda-next-line
      "k"   'org-agenda-previous-line
      "gj"  'org-agenda-next-item
      "gk"  'org-agenda-previous-item
      "0"   'digit-argument
      "gg"  'evil-goto-first-line
      "G"   'evil-goto-line
      "f"   'org-agenda-later
      "b"   'org-agenda-earlier
      "."   'org-agenda-goto-today
      "vd"  'org-agenda-day-view
      "vw"  'org-agenda-week-view
      "vm"  'org-agenda-month-view
      (kbd "RET") 'org-agenda-goto
      "t"   'org-agenda-todo
      "s"   'org-agenda-schedule
      "d"   'org-agenda-deadline
      "r"   'org-agenda-redo
      "u"   'org-agenda-undo
      "q"   'org-agenda-quit)))

;; Evil bindings for non-editing buffers (magit, dired, help, etc.)
(use-package evil-collection
  :after evil
  :config
  (evil-collection-init))

;; cs'" to change surrounding quotes, ysiw) to wrap word in parens
(use-package evil-surround
  :after evil
  :config
  (global-evil-surround-mode 1))

;; gc to toggle comments
(use-package evil-commentary
  :after evil
  :config
  (evil-commentary-mode))

;;;; ————————————————————————————————————————————————————————————
;;;; which-key
;;;; ————————————————————————————————————————————————————————————

;; Shows available keybindings in a popup after pressing a prefix
(use-package which-key
  :demand t
  :config
  (setq which-key-idle-delay 0.3)
  (which-key-mode)
  ;; Dismiss which-key popup when minibuffer opens (e.g. SPC / search)
  (add-hook 'minibuffer-setup-hook #'which-key--hide-popup))

;;;; ————————————————————————————————————————————————————————————
;;;; Leader keys (general.el)
;;;; ————————————————————————————————————————————————————————————

;; SPC-prefixed leader key definitions
(use-package general
  :demand t
  :config
  (general-create-definer my/leader-def
    :states '(normal visual emacs)
    :keymaps 'override
    :prefix "SPC"
    :global-prefix "C-SPC")

  ;; Quick access
  (my/leader-def
    "."  '(find-file :wk "find file")
    ","  '(consult-buffer :wk "switch buffer")
    "i"  '(my/search-org-files :wk "search org files")
    "x"  '(execute-extended-command :wk "M-x")
    "k"  '(delete-window :wk "kill window")
    "1"  '(delete-other-windows :wk "only this window")
    "2"  '(split-window-below :wk "split horizontal")
    "3"  '(split-window-right :wk "split vertical"))

  ;; File
  (my/leader-def
    "f"  '(:ignore t :wk "file")
    "ff" '(find-file :wk "find file")
    "fo" '(my/find-org-file :wk "find org file")
    "fr" '(consult-recent-file :wk "recent files")
    "fi" '(my/find-init-file :wk "open init.el"))

  ;; Buffer
  (my/leader-def
    "b"  '(:ignore t :wk "buffer")
    "bb" '(consult-buffer :wk "switch buffer")
    "bd" '(kill-current-buffer :wk "kill buffer")
    "bs" '(save-buffer :wk "save buffer"))

  ;; Search
  (my/leader-def
    "s"  '(:ignore t :wk "search")
    "ss" '(consult-line :wk "search in buffer")
    "so" '(my/search-org-files :wk "search org files")
    "sg" '(consult-ripgrep :wk "ripgrep"))

  ;; Org
  (my/leader-def
    "o"  '(:ignore t :wk "org")
    "oa" '(org-agenda :wk "agenda")
    "oc" '(org-capture :wk "capture")
    "ol" '(org-store-link :wk "store link")
    "ot" '(org-todo :wk "toggle todo")
    "os" '(org-schedule :wk "schedule")
    "od" '(org-deadline :wk "deadline")
    "or" '(org-refile :wk "refile")
    "oq" '(org-ql-search :wk "query org files")
    "ov" '(org-ql-view :wk "saved views"))

  ;; Save
  (my/leader-def
    "w"  '(save-buffer :wk "save file"))

  ;; Help
  (my/leader-def
    "h"  '(:ignore t :wk "help")
    "hf" '(describe-function :wk "describe function")
    "hv" '(describe-variable :wk "describe variable")
    "hk" '(describe-key :wk "describe key"))

  ;; Quit
  (my/leader-def
    "q"  '(:ignore t :wk "quit")
    "qq" '(save-buffers-kill-emacs :wk "quit")
    "qr" '(my/reload-config :wk "reload config")))

;;;; ————————————————————————————————————————————————————————————
;;;; Completion — Vertico + Orderless + Consult + Marginalia + Embark
;;;; ————————————————————————————————————————————————————————————

;; Vertical completion UI for minibuffer (file/buffer/command selection)
(use-package vertico
  :init (vertico-mode)
  :config
  (setq vertico-cycle t
        vertico-count 15))

;; Fuzzy/out-of-order matching for completion (fzf-like)
(use-package orderless
  :config
  (setq completion-styles '(orderless basic)
        completion-category-defaults nil
        completion-category-overrides '((file (styles orderless partial-completion basic)))
        orderless-matching-styles '(orderless-flex)))

;; Rich annotations next to completion candidates (docstrings, file sizes, etc.)
(use-package marginalia
  :init (marginalia-mode))

;; Enhanced search and navigation commands (ripgrep, buffer switch, line search)
(use-package consult
  :config
  (setq consult-narrow-key "<"
        consult-preview-key '(:debounce 0.3 any)))

;; Context actions on completion candidates (C-. to act on selected item)
(use-package embark
  :bind (("C-." . embark-act)
         ("C-;" . embark-dwim))
  :config
  (setq prefix-help-command #'embark-prefix-help-command))

;; Live preview when browsing consult results via embark
(use-package embark-consult
  :demand t
  :after (embark consult)
  :hook (embark-collect-mode . consult-preview-at-point-mode))

;; Async fuzzy finder — fzf-like fuzzy grep/find using orderless
(use-package affe
  :after orderless
  :config
  (defun affe-orderless-regexp-compiler (input _type _ignorecase)
    (setq input (cdr (orderless-compile input)))
    (cons input (apply-partially #'orderless--highlight input t)))
  (setq affe-regexp-compiler #'affe-orderless-regexp-compiler)
  (consult-customize affe-grep :preview-key '(:debounce 0.3 any)))

;;;; ————————————————————————————————————————————————————————————
;;;; Corfu — in-buffer completion popup
;;;; ————————————————————————————————————————————————————————————

;; In-buffer completion popup (like VSCode autocomplete)
(use-package corfu
  :init (global-corfu-mode)
  :config
  (setq corfu-auto t
        corfu-auto-prefix 1
        corfu-auto-delay 0.1
        corfu-cycle t
        corfu-quit-no-match t)
  ;; No dictionary/ispell completions in org-mode — only wiki-links, org, and file paths
  (add-hook 'org-mode-hook
            (lambda ()
              (setq-local completion-at-point-functions
                          (list #'my/org-wiki-capf
                                #'pcomplete-completions-at-point
                                #'cape-file)))))

;; Extra completion backends for corfu (file paths, dabbrev, etc.)
(use-package cape)

;;;; ————————————————————————————————————————————————————————————
;;;; Custom navigation functions
;;;; ————————————————————————————————————————————————————————————

(defvar my/org-directory "~/cloud/utils/org/")

(defun my/find-org-file ()
  "Fuzzy-find a file in the org directory."
  (interactive)
  (affe-find my/org-directory))

(defun my/reload-config ()
  "Reload init.el and refresh active modes in all org buffers."
  (interactive)
  (load-file (expand-file-name "init.el" user-emacs-directory))
  (dolist (buf (buffer-list))
    (with-current-buffer buf
      (when (derived-mode-p 'org-mode)
        (when (bound-and-true-p olivetti-mode)
          (olivetti-mode -1)
          (olivetti-mode 1)))))
  (message "Config reloaded."))

(defun my/search-org-files ()
  "Search org vault — file names and content with preview."
  (interactive)
  (let* ((dir (expand-file-name my/org-directory))
         (default-directory dir))
    (consult--multi
     (list
      (list :name "Files" :narrow ?f :category 'file
            :face 'consult-file
            :items (lambda ()
                     (mapcar (lambda (f) (file-relative-name f dir))
                             (directory-files-recursively dir "\\.org$")))
            :state (lambda ()
                     (let ((open (consult--temporary-files)))
                       (lambda (action cand)
                         (unless cand (funcall open))
                         (when (and cand (eq action 'preview))
                           (when-let ((buf (funcall open (expand-file-name cand dir))))
                             (consult--buffer-action buf))))))
            :action (lambda (f) (find-file (expand-file-name f dir))))
      (list :name "Content" :narrow ?c
            :items (lambda ()
                     (mapcar (lambda (l) (string-remove-prefix "./" l))
                             (split-string
                              (shell-command-to-string
                               "rg --no-heading --with-filename --line-number --color=never -v '^$' .")
                              "\n" t)))
            :state (lambda ()
                     (let ((open (consult--temporary-files)))
                       (lambda (action cand)
                         (unless cand (funcall open))
                         (when (and cand (eq action 'preview))
                           (when (string-match "\\`\\([^:]+\\):\\([0-9]+\\):" cand)
                             (when-let ((buf (funcall open (expand-file-name (match-string 1 cand) dir))))
                               (consult--buffer-action buf)
                               (goto-char (point-min))
                               (forward-line (1- (string-to-number (match-string 2 cand))))
                               (recenter)))))))
            :action (lambda (item)
                      (when (string-match "\\`\\([^:]+\\):\\([0-9]+\\):" item)
                        (find-file (expand-file-name (match-string 1 item) dir))
                        (goto-char (point-min))
                        (forward-line (1- (string-to-number (match-string 2 item))))
                        (recenter)))))
     :prompt "Search org: "
     :sort nil)))

(defun my/find-init-file ()
  "Open init.el."
  (interactive)
  (find-file (expand-file-name "init.el" user-emacs-directory)))

;;;; ————————————————————————————————————————————————————————————
;;;; Org mode
;;;; ————————————————————————————————————————————————————————————

;; Org-mode — notes, tasks, agenda, and document authoring
(use-package org
  :ensure nil
  :hook ((org-mode . variable-pitch-mode)
         (org-mode . visual-line-mode))
  :config
  (require 'org-tempo)
  (setq org-directory my/org-directory
        org-default-notes-file (expand-file-name "inbox.org" my/org-directory)
        org-agenda-files (list my/org-directory)
        org-startup-indented t
        org-startup-folded 'overview
        org-hide-leading-stars t
        org-hide-emphasis-markers t
        org-pretty-entities t
        org-ellipsis " ..."
        org-return-follows-link t
        org-image-actual-width '(500)
        org-auto-align-tags nil
        org-tags-column 0
        org-catch-invisible-edits 'show-and-error
        org-special-ctrl-a/e t
        org-insert-heading-respect-content t
        org-fontify-quote-and-verse-blocks t)

  ;; TODO workflow
  (setq org-todo-keywords
        '((sequence "TODO(t)" "NEXT(n)" "WAITING(w@)" "|" "DONE(d!)" "CANCELLED(c!)")
          (sequence "SOMEDAY(s)" "|")))
  (setq org-todo-keyword-faces
        '(("TODO"      . (:foreground "#ffe59e" :background "#282c34" :weight bold))
          ("NEXT"      . (:foreground "#282c34" :background "#79dcaa" :weight bold))
          ("WAITING"   . (:foreground "#282c34" :background "#ffe59e" :weight bold))
          ("SOMEDAY"   . (:foreground "#282c34" :background "#a8a8a8" :weight bold))
          ("CANCELLED" . (:foreground "#888888" :strike-through t))))
  (setq org-log-done 'time
        org-log-into-drawer t)

  ;; Tags
  (setq org-tag-alist
        '(("@work" . ?w)
          ("@home" . ?h)
          ("@errand" . ?e)
          ("@computer" . ?c)
          ("@read" . ?r)))

  ;; Refile
  (setq org-refile-targets
        '((org-agenda-files :maxlevel . 2))
        org-refile-use-outline-path 'file
        org-outline-path-complete-in-steps nil)

  ;; Agenda
  (setq org-agenda-window-setup 'current-window
        org-agenda-span 'week
        org-agenda-start-with-log-mode t)

  (setq org-agenda-custom-commands
        '(("d" "Dashboard"
           ((agenda "" ((org-agenda-span 'day)))
            (todo "NEXT" ((org-agenda-overriding-header "In Progress")))
            (todo "WAITING" ((org-agenda-overriding-header "Waiting On")))))
          ("n" "Next actions" todo "NEXT")
          ("w" "Waiting" todo "WAITING")))

  ;; Follow links with RET in normal mode
  (evil-define-key 'normal org-mode-map (kbd "RET") 'org-open-at-point)

  ;; Capture templates
  (setq org-capture-templates
        `(("t" "Task" entry (file+headline org-default-notes-file "Tasks")
           "* TODO %?\n  %U\n  %a" :empty-lines 1)
          ("n" "Note" entry (file+headline org-default-notes-file "Notes")
           "* %?\n  %U" :empty-lines 1)
          ("j" "Journal" entry (file+olp+datetree
                                ,(expand-file-name "journal.org" my/org-directory))
           "* %?\n  %U" :empty-lines 1)
          ("m" "Meeting" entry (file+headline
                                ,(expand-file-name "notes.org" my/org-directory)
                                "Meetings")
           "* %? :meeting:\n  %U\n  %a" :empty-lines 1))))

;;;; ————————————————————————————————————————————————————————————
;;;; Obsidian-style [[wiki links]] for org-mode
;;;; ————————————————————————————————————————————————————————————

;; Resolve [[link]] against files in `my/org-directory' by basename or #+title:.
;; Intercepts org's fuzzy-link resolver before its buffer-local fallback.

(defun my/org-wiki--files ()
  "Return all .org files under `my/org-directory' recursively."
  (let ((dir (expand-file-name my/org-directory)))
    (when (file-directory-p dir)
      (directory-files-recursively dir "\\.org\\'"))))

(defun my/org-wiki--file-title (file)
  "Return the #+title: of FILE, or nil. Reads only the header region."
  (ignore-errors
    (with-temp-buffer
      (insert-file-contents file nil 0 4096)
      (goto-char (point-min))
      (when (re-search-forward "^#\\+title:[ \t]*\\(.+?\\)[ \t]*$" nil t)
        (match-string-no-properties 1)))))

(defvar my/org-wiki--cache nil
  "Cached (MTIME . CANDIDATES) for the org vault.
CANDIDATES is the alist returned by `my/org-wiki--candidates'.")

(defun my/org-wiki--vault-mtime ()
  "Return the mtime of the vault root, or nil if it doesn't exist."
  (let ((dir (expand-file-name my/org-directory)))
    (and (file-directory-p dir)
         (file-attribute-modification-time (file-attributes dir)))))

(defun my/org-wiki--build-candidates ()
  "Scan the vault and return an alist of (NAME . FILE) entries.
Each file contributes its basename (sans .org) and its #+title: if present."
  (let (cands)
    (dolist (f (my/org-wiki--files))
      (let ((base (ignore-errors (file-name-base f)))
            (title (my/org-wiki--file-title f)))
        (when base (push (cons base f) cands))
        (when (and title (not (equal title base)))
          (push (cons title f) cands))))
    (nreverse cands)))

(defun my/org-wiki--candidates ()
  "Return cached vault candidates. Rebuilds when vault dir mtime changes."
  (let ((mtime (my/org-wiki--vault-mtime)))
    (unless (and my/org-wiki--cache (equal (car my/org-wiki--cache) mtime))
      (setq my/org-wiki--cache (cons mtime (my/org-wiki--build-candidates))))
    (cdr my/org-wiki--cache)))

(defun my/org-wiki-refresh ()
  "Force-refresh the wiki-link candidate cache."
  (interactive)
  (setq my/org-wiki--cache nil)
  (let ((n (length (my/org-wiki--candidates))))
    (message "Wiki cache rebuilt: %d entries" n)))

(defun my/org-wiki--resolve (name)
  "Return file for NAME, a list of files if ambiguous, or nil."
  (let* ((needle (downcase (string-trim name)))
         (hits (delete-dups
                (mapcar #'cdr
                        (seq-filter
                         (lambda (c) (string= (downcase (car c)) needle))
                         (my/org-wiki--candidates))))))
    (pcase hits
      (`nil nil)
      (`(,only) only)
      (_ hits))))

(defun my/org-wiki--local-anchor-p (name)
  "Non-nil if NAME matches a heading or <<target>> in the current buffer."
  (save-excursion
    (goto-char (point-min))
    (let ((case-fold-search t)
          (q (regexp-quote name)))
      (or (re-search-forward (format "^\\*+[ \t]+%s\\([ \t]+:.*:\\)?[ \t]*$" q) nil t)
          (re-search-forward (format "<<%s>>" q) nil t)))))

(defun my/org-wiki--create (name)
  "Create NAME.org in the vault root with a #+title: header and open it."
  (let ((file (expand-file-name (concat name ".org")
                                (expand-file-name my/org-directory))))
    (find-file file)
    (when (zerop (buffer-size))
      (insert (format "#+title: %s\n\n" name))
      (save-buffer))))

(defun my/org-wiki-follow ()
  "Follow a fuzzy [[link]] against the org vault.
Return t if handled, nil to let org's default resolver continue.
Added to `org-open-at-point-functions'."
  (let ((ctx (org-element-context)))
    (when (eq (org-element-type ctx) 'link)
      (let ((type (org-element-property :type ctx))
            (path (org-element-property :path ctx)))
        (when (and (equal type "fuzzy")
                   (stringp path)
                   (not (string-match-p "\\`[*#]" path))
                   (not (my/org-wiki--local-anchor-p path)))
          (pcase (my/org-wiki--resolve path)
            ((and (pred stringp) file)
             (find-file file) t)
            ((and (pred listp) files)
             (find-file (completing-read
                         (format "Matches for \"%s\": " path)
                         files nil t))
             t)
            (_
             (when (y-or-n-p (format "Create new note \"%s\"? " path))
               (my/org-wiki--create path)
               t))))))))

(add-hook 'org-open-at-point-functions #'my/org-wiki-follow)

(defun my/org-insert-wiki-link ()
  "Insert a [[wiki link]] by picking a vault file via `completing-read'."
  (interactive)
  (let* ((names (delete-dups (mapcar #'car (my/org-wiki--candidates))))
         (pick (completing-read "Wiki link: " names nil nil)))
    (insert (format "[[%s]]" pick))))

(with-eval-after-load 'org
  (define-key org-mode-map (kbd "C-c n i") #'my/org-insert-wiki-link))

(defun my/org-wiki-capf ()
  "Completion-at-point for unclosed [[...] inside org-mode.
Errors inside the capf are swallowed so completion can't crash typing."
  (condition-case err
      (when (derived-mode-p 'org-mode)
        (let ((pt (point)))
          (save-excursion
            (when (re-search-backward "\\[\\[" (line-beginning-position) t)
              (let ((start (match-end 0)))
                (unless (save-excursion
                          (goto-char start)
                          (re-search-forward "\\]\\]" pt t))
                  (list start pt
                        (mapcar #'car (my/org-wiki--candidates))
                        :exclusive 'no)))))))
    (error
     (message "my/org-wiki-capf: %s" (error-message-string err))
     nil)))

(defun my/org-wiki--maybe-complete ()
  "Trigger `completion-at-point' right after `[[' is typed.
Corfu's `corfu-auto-prefix' won't popup on a zero-length prefix,
so we nudge it manually. Bound to `post-self-insert-hook' in org buffers."
  (when (and (eq last-command-event ?\[)
             (>= (- (point) (point-min)) 2)
             (string= "[[" (buffer-substring-no-properties
                            (- (point) 2) (point))))
    (completion-at-point)))

(add-hook 'org-mode-hook
          (lambda ()
            (add-hook 'post-self-insert-hook
                      #'my/org-wiki--maybe-complete nil t)))

;;;; ————————————————————————————————————————————————————————————
;;;; Variable-pitch rendering — mixed-pitch
;;;; ————————————————————————————————————————————————————————————

;; Proportional font for prose, monospace for code/tables/metadata
(use-package mixed-pitch
  :hook (org-mode . mixed-pitch-mode)
  :config
  (setq mixed-pitch-set-height nil))

;;;; ————————————————————————————————————————————————————————————
;;;; org-modern — pretty headings, keywords, tables
;;;; ————————————————————————————————————————————————————————————

;; Modern styling for org — bullet points, TODO badges, tables
(use-package org-modern
  :hook ((org-mode . org-modern-mode)
         (org-agenda-finalize . org-modern-agenda))
  :config
  (setq org-modern-star '("◉" "○" "◈" "◇" "▸")
        org-modern-hide-stars nil
        org-modern-table-vertical 1
        org-modern-table-horizontal 0.2
        org-modern-block-fringe nil
        org-modern-todo-faces
        '(("TODO"      :foreground "#ffe59e" :background "#282c34" :weight bold)
          ("NEXT"      :background "#79dcaa" :foreground "#282c34")
          ("WAITING"   :background "#ffe59e" :foreground "#282c34")
          ("SOMEDAY"   :background "#a8a8a8" :foreground "#282c34")
          ("CANCELLED" :background "#555555" :foreground "#888888")
          ("DONE"      :background "#282c34" :foreground "#aaaaaa" :strike-through t))))

;;;; ————————————————————————————————————————————————————————————
;;;; org-ql — query org files as a database
;;;; ————————————————————————————————————————————————————————————

;; SQL-like queries across org files (search, views, dynamic block tables)
(use-package org-ql
  :config
  (require 'org-ql-search)
  (setq org-ql-search-directories-files-recursive t))

;;;; ————————————————————————————————————————————————————————————
;;;; Raw view in insert mode
;;;; ————————————————————————————————————————————————————————————

;; In insert mode: show raw org syntax (#+, *, emphasis markers)
;; In normal mode: restore pretty rendering
(defun my/org-enter-insert ()
  (when (derived-mode-p 'org-mode)
    (when (bound-and-true-p org-modern-mode)
      (org-modern-mode -1))
    (setq-local org-hide-emphasis-markers nil)
    (font-lock-fontify-buffer)))

(defun my/org-exit-insert ()
  (when (derived-mode-p 'org-mode)
    (setq-local org-hide-emphasis-markers t)
    (font-lock-fontify-buffer)
    (org-modern-mode 1)))

(add-hook 'evil-insert-state-entry-hook #'my/org-enter-insert)
(add-hook 'evil-insert-state-exit-hook  #'my/org-exit-insert)

;;;; ————————————————————————————————————————————————————————————
;;;; Olivetti — centered, readable text width
;;;; ————————————————————————————————————————————————————————————

(setq olivetti-body-width 120
      olivetti-minimum-body-width 60)

;; Centers text with wide margins for distraction-free writing
(use-package olivetti
  :hook (org-mode . olivetti-mode))

;;;; ————————————————————————————————————————————————————————————
;;;; Quality of life (all built-in)
;;;; ————————————————————————————————————————————————————————————

;; Tracks recently opened files
(use-package recentf
  :ensure nil
  :config
  (setq recentf-max-saved-items 50)
  (recentf-mode 1))

;; Remembers cursor position in previously visited files
(use-package saveplace
  :ensure nil
  :init (save-place-mode 1))

;; Persists minibuffer history across sessions
(use-package savehist
  :ensure nil
  :init (savehist-mode 1))
