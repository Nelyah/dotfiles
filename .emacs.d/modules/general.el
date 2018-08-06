(use-package general)

;; * Global Keybindings
;; `general-define-key' acts like `evil-define-key' when :states is specified
(general-define-key
 :states 'motion
 ;; swap ; and :
 ";" 'evil-ex
 ":" 'evil-repeat-find-char)
;; same as
(general-define-key
 :states 'motion
 ";" 'evil-ex
 ":" 'evil-repeat-find-char)
;; `general-def' can be used instead for `evil-global-set-key'-like syntax
(general-def 'motion
  ";" 'evil-ex
  ":" 'evil-repeat-find-char)

;; alternative using `general-translate-key'
;; swap ; and : in `evil-motion-state-map'
(general-swap-key nil 'motion
  ";" ":")

;; * Mode Keybindings
(general-define-key
 :states 'normal
 :keymaps 'emacs-lisp-mode-map
 ;; or xref equivalent
 "K" 'elisp-slime-nav-describe-elisp-thing-at-point)
;; `general-def' can be used instead for `evil-define-key'-like syntax
(general-def 'normal emacs-lisp-mode-map
  "K" 'elisp-slime-nav-describe-elisp-thing-at-point)

;; * Prefix Keybindings
;; :prefix can be used to prevent redundant specification of prefix keys
;; again, variables are not necessary and likely not useful if you are only
;; using a definer created with `general-create-definer' for the prefixes
;; (defconst my-leader "SPC")
;; (defconst my-local-leader "SPC m")

(general-create-definer my-leader-def
  ;; :prefix my-leader
  :prefix "SPC")

(general-create-definer my-local-leader-def
  ;; :prefix my-local-leader
  :prefix "SPC m")

;; ** Global Keybindings
(my-leader-def
  :keymaps 'normal
  ;; bind "SPC a"
  "a" 'org-agenda
  "b" 'counsel-bookmark
  "c" 'org-capture)
;; `general-create-definer' creates wrappers around `general-def', so
;; `evil-global-set-key'-like syntax is also supported
(my-leader-def 'normal
  "a" 'org-agenda
  "b" 'counsel-bookmark
  "c" 'org-capture)

;; to prevent your leader keybindings from ever being overridden (e.g. an evil
;; package may bind "SPC"), use :keymaps 'override
(my-leader-def
  :states 'normal
  :keymaps 'override
  "a" 'org-agenda)
;; or
(my-leader-def 'normal 'override
  "a" 'org-agenda)

;; ** Mode Keybindings
(my-local-leader-def
  :states 'normal
  :keymaps 'org-mode-map
  "y" 'org-store-link
  "p" 'org-insert-link
  ;; ...
  )
;; `general-create-definer' creates wrappers around `general-def', so
;; `evil-define-key'-like syntax is also supported
(my-local-leader-def 'normal org-mode-map
  "y" 'org-store-link
  "p" 'org-insert-link
  ;; ...
  )

;; * Setings
;; change evil's search module after evil has been loaded (`setq' will not work)
(general-setq evil-search-module 'evil-search)
