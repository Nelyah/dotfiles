(require 'package)
(setq package-enable-at-startup nil)
(add-to-list 'package-archives
         '("melpa" . "https://melpa.org/packages/"))
(add-to-list 'package-archives
         '("melpa2" . "http://www.mirrorservice.org/sites/melpa.org/packages/"))
(add-to-list 'package-archives
         '("melpa3" . "http://www.mirrorservice.org/sites/stable.melpa.org/packages/"))
(package-initialize)

;; Bootstrap `use-package'
(unless (package-installed-p 'use-package)
    (package-refresh-contents)
    (package-install 'use-package))


(org-babel-load-file "~/.emacs.d/myinit.org")


;; (require 'package)

;; (add-to-list 'package-archives '("org" . "https://orgmode.org/elpa/") t)
;; (add-to-list 'package-archives '("melpa" . "http://melpa.org/packages/"))
;; (add-to-list 'package-archives '("melpa-stable" . "http://stable.melpa.org/packages/"))
;; (package-initialize)

;; ;UTF-8 but do not mess with line endings
;; (if (eq system-type 'windows-nt)
;;     (prefer-coding-system 'utf-8-dos)
;;   (prefer-coding-system 'utf-8-unix))


;; (show-paren-mode 1) ;; turn on bracket match highlight
;; (define-key global-map (kbd "RET") 'newline-and-indent) ;; Auto indent
;; (global-auto-revert-mode 1) ;; when a file is updated outside emacs, make it update if it's already opened in emacs

;; ;; Turn off mouse interface early in startup to avoid momentary display.
;; (if (fboundp 'menu-bar-mode) (menu-bar-mode -1))
;; (if (fboundp 'tool-bar-mode) (tool-bar-mode -1))
;; (if (fboundp 'scroll-bar-mode) (scroll-bar-mode -1))

;; ;; No splash screen please.
;; (setq inhibit-startup-message t)

;; ;; No fascists.
;; (setq initial-scratch-message nil)

;; ;; Productive default mode
;; (setq initial-major-mode 'org-mode)

;; ;; No alarms.
;; (setq ring-bell-function 'ignore)

;; ;; When on a tab, make the cursor the tab length.
;; (setq-default x-stretch-cursor t)


;; ;; Write backup files to own directory
;; (setq backup-directory-alist
;;       `(("." . ,(expand-file-name
;;                  (concat user-emacs-directory "backups")))))

;; ;; Make backups of files, even when they're in version control.
;; (setq vc-make-backup-files t)

;; ;; Save point position between sessions.
;; ;(use-package saveplace)
;; ;(setq-default save-place t)
;; ;(setq save-place-file (expand-file-name "places" user-emacs-directory))

;; ;;; Fix empty pasteboard error.
;; (setq save-interprogram-paste-before-kill nil)

;; ;; Don't automatically copy selected text
;; (setq select-enable-primary nil)

;; ;; Enable some commands.
;; (put 'downcase-region 'disabled nil)
;; (put 'upcase-region 'disabled nil)
;; (put 'narrow-to-region 'disabled nil)
;; (put 'erase-buffer 'disabled nil)

;; ;; Add filepath to frame title
;; (setq-default frame-title-format
;;               '(:eval (format "%s (%s)"
;;                               (buffer-name)
;;                               (when (buffer-file-name)
;;                                 (abbreviate-file-name (buffer-file-name))))))


;; (unless (package-installed-p 'use-package)
;;   (package-refresh-contents)
;;   (package-install 'use-package))

;; (eval-when-compile
;;   (require 'use-package))
;; (require 'bind-key)                ;; if you use any :bind variant


;; (setq use-package-always-ensure t) ; Make sure we always install them if they are not already
;; (setq package-enable-at-startup nil)



;; ;; ;; (load "~/.emacs.d/modules/module.el")
;; ;; (load "~/.emacs.d/modules/functions.el")
;; ;; (load "~/.emacs.d/modules/org.el")
;; ;; (load "~/.emacs.d/modules/evil.el")
;; ;; (load "~/.emacs.d/modules/helm.el")
;; ;; (load "~/.emacs.d/modules/hydra.el")
;; ;; (load "~/.emacs.d/modules/general.el")
;; ;; (load "~/.emacs.d/modules/fzf.el")
;; ;; (load "~/.emacs.d/modules/company.el")
;; ;; (load "~/.emacs.d/modules/magit.el")

;; ;; (load "~/.emacs.d/modules/configs.el")
;; ;; (load "~/.emacs.d/modules/markdown.el")
;; ;; (load "~/.emacs.d/modules/json.el")
;; ;; (load "~/.emacs.d/modules/docker.el")
;; ;; (load "~/.emacs.d/modules/xml.el")
;; ;; (load "~/.emacs.d/modules/yaml.el")

;; ;; (load "~/.emacs.d/modules/sql.el")
;; ;; (load "~/.emacs.d/modules/php.el")
;; ;; (load "~/.emacs.d/modules/python.el")
;; ;; (load "~/.emacs.d/modules/java.el")
;; ;; (load "~/.emacs.d/modules/javascript.el")
;; ;; (load "~/.emacs.d/modules/clang.el")

;; ;; (load "~/.emacs.d/modules/bindings.el")
;; ;; (load "~/.emacs.d/modules/my-defaults.el")


;; ; Theme




