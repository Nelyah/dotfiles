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

(general-create-definer my-leader-def
  ;; :prefix my-leader
  :prefix "SPC")


(defun general/remap-range (begin-key end-key make-leader-binding &optional reserved)
  "Remap a range of keys from 'ctl-x-map', from BEGIN-KEY to END-KEY inclusive to an Evil leader binding.
Convert the key from the map to an Evil leader binding using MAKE-LEADER-BINDING.
RESERVED is a list of keys: if specified, do not create bindings for these."
  (let ((bindings-plist '()))
    (map-char-table
     (lambda (key value)
       (when (and (>= key begin-key)
                  (<= key end-key)
                  (not (member key reserved)))
         (add-to-list 'bindings-plist (funcall make-leader-binding key) t)
         (add-to-list 'bindings-plist value t)))
     (cadr ctl-x-map))
    (apply 'general-define-key :states 'normal :prefix "SPC" bindings-plist)))


(mapcar
 (lambda (prefix-key)
   (general/remap-range ?\C-a
                        ?\C-z
                        (lambda (key) (format "%c%s" prefix-key (char-to-string (+ 96 key))))))
 '(?f ?x))


(general/remap-range ?0
                     ?z
                     (lambda (key) (char-to-string key))
                     '(?f ?m ?r ?s ?t ?d))


(general-define-key
 :prefix "SPC"
 :states '(normal visual emacs)
 :keymaps 'override
 "w" 'save-buffer
 "b" 'fzf-switch-buffer
 "c" 'comment-region
 "C" 'uncomment-region
 "n" 'treemacs
 "X" 'delete-trailing-whitespace
 "p" '(:keymap projectile-command-map :package projectile) ;; Switch to projectile mode
 "o" '(:keymap org-capture-mode-map :package org) ;; Switch to projectile mode
)

(general-define-key
 :states '(normal emacs)
 :keymaps 'override
 "M-l" 'evil-window-right
 "M-h" 'evil-window-left
 "M-k" 'evil-window-up
 "M-j" 'evil-window-down
)


(general-define-key
 :prefix "SPC m"
 :keymaps 'override
 :states '(normal emacs)
 "a" 'apache-mode
 "d" 'markdown-mode
 "h" 'html-mode
 "j" 'javascript-mode
 "n" 'nginx-mode
 "o" 'org-mode
 "p" 'python-mode
 "s" 'shell-script-mode
 "x" 'nxml-mode
 "y" 'syslog-mode
)

(general-define-key
 :prefix "SPC r"
 :keymaps 'override
 :states '(normal)
 "rd" 'run-dig ;; not exactly a REPL, but fits nonetheless
 "rf" 'run-fsharp
 "ri" 'ielm
 "rp" 'run-python
 )

(general-define-key
 :prefix "SPC f"
 :keymaps 'override
 :states '(normal)
 "i" 'find-init-file
 "o" 'fzf-find-file
 )

(general-define-key
 :prefix "SPC s"
 :keymaps 'override
 :states '(normal)
 "p" 'sql-postgres
 "s" 'sql-sqlite
)

(general-define-key
 :prefix "SPC g"
 :keymaps '(override magit-status-mode-map)
 :states '(normal)
 "s" 'magit-status
 "q" 'magit-quit-session
)

;; (evil-leader/set-key "p" 'popup-imenu)
(general-define-key
 :prefix "SPC j"
 :keymaps '(override json-mode)
 :states '(normal)
 "np" 'json-navigator-navigate-after-point
 "nr" 'json-navigator-navigate-region
 "pb" 'json-pretty-print-buffer
 "pr" 'json-pretty-print
 "r" 'json-reformat-region
 )


;; to prevent your leader keybindings from ever being overridden (e.g. an evil
;; package may bind "SPC"), use :keymaps 'override
;; (my-leader-def
;;   :states 'normal
;;   :keymaps 'override
;;   "a" 'org-agenda)
;; ;; or
;; (my-leader-def 'normal 'override
;;   "a" 'org-agenda)

;; ;; ** Mode Keybindings
;; (my-local-leader-def
;;   :states 'normal
;;   :keymaps 'org-mode-map
;;   "y" 'org-store-link
;;   "p" 'org-insert-link
;;   ;; ...
;;   )
;; ;; `general-create-definer' creates wrappers around `general-def', so
;; ;; `evil-define-key'-like syntax is also supported
;; (my-local-leader-def 'normal org-mode-map
;;   "y" 'org-store-link
;;   "p" 'org-insert-link
;;   )

;; * Setings
;; change evil's search module after evil has been loaded (`setq' will not work)
(general-setq evil-search-module 'evil-search)
(general-override-mode)




