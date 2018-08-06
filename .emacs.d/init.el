(require 'package)

(add-to-list 'package-archives '("org" . "http://orgmode.org/elpa/"))
(add-to-list 'package-archives '("melpa" . "http://melpa.org/packages/"))
(add-to-list 'package-archives '("melpa-stable" . "http://stable.melpa.org/packages/"))
(package-initialize)

;UTF-8 but do not mess with line endings
(if (eq system-type 'windows-nt)
    (prefer-coding-system 'utf-8-dos)
  (prefer-coding-system 'utf-8-unix))


(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

(eval-when-compile
  (require 'use-package))
(require 'bind-key)                ;; if you use any :bind variant


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
    (magit docker-compose-mode dockerfile-mode docker projectile fzf company-statistics company-box treemacs all-the-icons-dired all-the-icons telephone-line paredit popup-imenu company-lsp lsp-ui flycheck lsp-mode which-key company-files company-keywords company evil-leader markdown-mode helm atom-dark-theme evil-visual-mark-mode))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(company-box-annotation ((t (:inherit company-tooltip-annotation :background "dim gray"))))
 '(company-box-background ((t (:inherit company-tooltip :background "#383c44" :box (:line-width 5 :color "grey75" :style released-button)))))
 '(company-box-selection ((t (:inherit company-tooltip-selection :foreground "sandy brown")))))
(setq use-package-always-ensure t) ; Make sure we always install them if they are not already
(setq package-enable-at-startup nil)



;; (load "~/.emacs.d/modules/module.el")
(load "~/.emacs.d/modules/functions.el")
(load "~/.emacs.d/modules/evil.el")
(load "~/.emacs.d/modules/helm.el")
(load "~/.emacs.d/modules/hydra.el")
(load "~/.emacs.d/modules/general.el")
(load "~/.emacs.d/git_packages/fzf.el/fzf.el")
(load "~/.emacs.d/modules/company.el")
(load "~/.emacs.d/modules/magit.el")

(load "~/.emacs.d/modules/configs.el")
(load "~/.emacs.d/modules/markdown.el")
(load "~/.emacs.d/modules/json.el")
(load "~/.emacs.d/modules/docker.el")
(load "~/.emacs.d/modules/xml.el")
(load "~/.emacs.d/modules/yaml.el")

(load "~/.emacs.d/modules/sql.el")
(load "~/.emacs.d/modules/php.el")
(load "~/.emacs.d/modules/python.el")
(load "~/.emacs.d/modules/java.el")
(load "~/.emacs.d/modules/javascript.el")

(use-package csv-mode)

; Theme
(load-theme 'atom-one-dark t)

(fset 'yes-or-no-p 'y-or-n-p) ; set yes or no to y or n

(use-package which-key
  :config (which-key-mode)
  :demand
)

; Language Server Protocol
(use-package lsp-mode)
;; (use-package flycheck :config (add-hook 'prog-mode-hook 'flycheck-mode)) ;; used by lsp-ui for fancy displays
;; (use-package lsp-ui :config (add-hook 'lsp-mode-hook 'lsp-ui-mode))
;; (use-package paredit)

(use-package projectile
  :config
    (projectile-mode)
    (setq projectile-enable-caching t)
    (setq projectile-project-search-path '("~/projects/" "~/work/"))
    (evil-leader/set-key "p" 'projectile-command-map)
)

(add-hook 'emacs-lisp-mode-hook 'flycheck-mode)


(show-paren-mode 1) ;; turn on bracket match highlight
(define-key global-map (kbd "RET") 'newline-and-indent) ;; Auto indent
(global-auto-revert-mode 1) ;; when a file is updated outside emacs, make it update if it's already opened in emacs
(tool-bar-mode -1)
(menu-bar-mode -1)

(unless (frame-parameter nil 'tty)
    (scroll-bar-mode -1))

(setq inhibit-splash-screen t
      ring-bell-function 'ignore
      make-backup-files nil) ;; stop creating those backup~ files)

(add-hook 'prog-mode-hook 'column-number-mode)
(if (< emacs-major-version 26)
    (add-hook 'prog-mode-hook 'linum-mode)
  (add-hook 'prog-mode-hook 'enable-line-numbers))
(use-package popup-imenu)


(use-package telephone-line
  :config (progn
            (require 'telephone-line-config)
            (telephone-line-evil-config)
            (setq telephone-line-height 20)))
(use-package all-the-icons)

(use-package all-the-icons-dired
  :config (add-hook 'dired-mode-hook 'all-the-icons-dired-mode))

(use-package treemacs
  :config (add-to-list 'evil-emacs-state-modes  'treemacs-mode))


(defun set-x-caps-escape ()
"Set CAPSLOCK to be another ESC key in X."
(interactive)
(shell-command "setxkbmap -option caps:escape"))

