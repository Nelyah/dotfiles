(eval-when-compile
  (require 'use-package))
(require 'diminish)                ;; if you use :diminish
(require 'bind-key)                ;; if you use any :bind variant

(require 'package)

(add-to-list 'package-archives '("org" . "http://orgmode.org/elpa/"))
(add-to-list 'package-archives '("melpa" . "http://melpa.org/packages/"))
(add-to-list 'package-archives '("melpa-stable" . "http://stable.melpa.org/packages/"))
(package-initialize)

;UTF-8 but do not mess with line endings
(if (eq system-type 'windows-nt)
    (prefer-coding-system 'utf-8-dos)
  (prefer-coding-system 'utf-8-unix))

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-safe-themes
   (quote
    ("57f95012730e3a03ebddb7f2925861ade87f53d5bbb255398357731a7b1ac0e0" "76dc63684249227d64634c8f62326f3d40cdc60039c2064174a7e7a7a88b1587" default)))
 '(fci-rule-color "color-237")
 '(package-selected-packages
   (quote
    (fzf company-statistics company-box treemacs all-the-icons-dired all-the-icons telephone-line paredit popup-imenu company-lsp lsp-ui flycheck lsp-mode which-key company-files company-keywords company evil-leader markdown-mode helm atom-dark-theme evil-visual-mark-mode))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(company-box-annotation ((t (:inherit company-tooltip-annotation :background "dim gray"))))
 '(company-box-background ((t (:inherit company-tooltip :background "#383c44" :box (:line-width 2 :color "grey75" :style released-button)))))
 '(company-box-selection ((t (:inherit company-tooltip-selection :foreground "sandy brown")))))
;; '(company-box-annotation ((t (:inherit company-tooltip-annotation :background "dim gray"))))
;;  '(company-box-background ((t (:inherit company-tooltip :background "#383c44" :box (:line-width 2 :color "grey75" :style released-button)))))
;;  '(company-box-selection ((t (:inherit company-tooltip-selection :foreground "sandy brown"))))
; Always use the use-package forother packages
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

(require 'use-package)
(setq use-package-always-ensure t) ; Make sure we always install them if they are not already


(load "~/.emacs.d/my-module.el")
(load "~/.emacs.d/my-evil.el")
(load "~/.emacs.d/my-company.el")



(setq package-enable-at-startup nil)


; Theme
(load-theme 'atom-one-dark t)

(fset 'yes-or-no-p 'y-or-n-p) ; set yes or no to y or n

(use-package which-key
  :config (which-key-mode)
  :demand)

(use-package markdown-mode :ensure t)
(use-package helm
  :diminish helm-mode
  :init
  (progn
    (require 'helm-config)
    (setq helm-candidate-number-limit 100)
    ;; From https://gist.github.com/antifuchs/9238468
    (setq helm-idle-delay 0.0 ; update fast sources immediately (doesn't).
          helm-input-idle-delay 0.01  ; this actually updates things
                                        ; reeeelatively quickly.
          helm-split-window-in-side-p           t ; open helm buffer inside current window, not occupy whole other window
          helm-ff-search-library-in-sexp        t ; search for library in `require' and `declare-function' sexp.
          helm-yas-display-key-on-candidate t
          helm-quick-update t
          helm-M-x-requires-pattern nil
          helm-mode-fuzzy-match t
          helm-completion-in-region-fuzzy-match t
          helm-M-x-fuzzy-match t
          helm-ff-skip-boring-files t)
    (helm-mode))
  :bind (("C-c h" . helm-mini)
         ("C-h a" . helm-apropos)
         ("C-x C-b" . helm-buffers-list)
         ("C-x b" . helm-buffers-list)
         ("M-y" . helm-show-kill-ring)
         ("M-x" . helm-M-x)
         ("C-x c o" . helm-occur)
         ("C-x c s" . helm-swoop)
         ("C-x c y" . helm-yas-complete)
         ("C-x c Y" . helm-yas-create-snippet-on-region)
         ("C-x c b" . my/helm-do-grep-book-notes)
         ("M-x" . helm-M-x)
         ("C-x c SPC" . helm-all-mark-rings))
  )


(use-package helm-swoop
 :bind
 (("M-I" . helm-swoop-back-to-last-point)
  ("C-c M-i" . helm-multi-swoop)
  ("C-x M-i" . helm-multi-swoop-all)
  )
 :config
 (progn
   (define-key isearch-mode-map (kbd "M-i") 'helm-swoop-from-isearch)
   (define-key helm-swoop-map (kbd "M-i") 'helm-multi-swoop-all-from-helm-swoop))
)

; Language Server Protocol
(use-package lsp-mode)
(use-package flycheck :config (add-hook 'prog-mode-hook 'flycheck-mode)) ;; used by lsp-ui for fancy displays

(use-package lsp-ui :config (add-hook 'lsp-mode-hook 'lsp-ui-mode))
(use-package paredit)

;; (add-hook 'emacs-lisp-mode-hook 'prettify-symbols-mode)
;; (add-hook 'emacs-lisp-mode-hook 'paredit-mode)
; (add-hook 'emacs-lisp-mode-hook 'eldoc-mode)
(add-hook 'emacs-lisp-mode-hook 'flycheck-mode)



(use-package fzf)

(show-paren-mode 1) ;; turn on bracket match highlight
(setq make-backup-files nil) ;; stop creating those backup~ files
(define-key global-map (kbd "RET") 'newline-and-indent) ;; Auto indent
(global-auto-revert-mode 1) ;; when a file is updated outside emacs, make it update if it's already opened in emacs

(defun find-init-file ()
  (interactive)
  (find-file "~/.emacs.d/init.el")
)

(add-hook 'prog-mode-hook 'column-number-mode)

(defun enable-line-numbers ()
  (setq display-line-numbers t))

(if (< emacs-major-version 26)
    (add-hook 'prog-mode-hook 'linum-mode)
  (add-hook 'prog-mode-hook 'enable-line-numbers))
(use-package popup-imenu)

  


(tool-bar-mode -1)

(menu-bar-mode -1)
(unless (frame-parameter nil 'tty)
    (scroll-bar-mode -1))

(setq inhibit-splash-screen t
      ring-bell-function 'ignore)

(use-package telephone-line
  :config (progn
            (require 'telephone-line-config)
            (telephone-line-evil-config)
            (setq telephone-line-height 24)))
(use-package all-the-icons)

(use-package all-the-icons-dired
  :config (add-hook 'dired-mode-hook 'all-the-icons-dired-mode))

(use-package treemacs
  :config (add-to-list 'evil-emacs-state-modes  'treemacs-mode))

