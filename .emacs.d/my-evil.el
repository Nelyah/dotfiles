(use-package evil
  :demand
  :config (evil-mode 1))

(use-package evil-leader
  :demand
  :config (progn
            (setq evil-leader/in-all-states t)
            (global-evil-leader-mode)
            (evil-leader/set-leader "SPC")))
(setq-default indent-tabs-mode nil)


; Evil mode
(defun evil-leader/remap-range (begin-key end-key make-leader-binding &optional reserved)
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
    (apply 'evil-leader/set-key bindings-plist)))

(mapcar
 (lambda (prefix-key)
   (evil-leader/remap-range ?\C-a
                            ?\C-z
                            (lambda (key) (format "%c%s" prefix-key (char-to-string (+ 96 key))))))
 '(?f ?x))


(evil-leader/remap-range ?0
                         ?z
                         (lambda (key) (char-to-string key))
                         '(?f ?m ?r ?s ?t ?d))

(defun set-x-caps-escape ()
  "Set CAPSLOCK to be another ESC key in X."
  (interactive)
  (shell-command "setxkbmap -option caps:escape"))


(evil-leader/set-key
  "w" 'save-buffer
  "b" 'helm-buffer-list
  "k" 'kill-buffer
  "i" 'helm-swoop
  "c" 'comment-region
  "C" 'uncomment-region
  "n" 'treemacs
  "X" 'delete-trailing-whitespace)

(evil-leader/set-key
  "md" 'markdown-mode
  "mh" 'html-mode
  "mj" 'javascript-mode
  "mnc" 'column-number-mode
  "mnl" 'linum-mode
  "mo" 'org-mode
  "mp" 'python-mode
  "ms" 'shell-script-mode
  "mx" 'nxml-mode)

(evil-leader/set-key
  "rd" 'run-dig ;; not exactly a REPL, but fits nonetheless
  "rf" 'run-fsharp
  "ri" 'ielm
  "rp" 'run-python)

(evil-leader/set-key
  "fi" 'find-init-file
  "fo" 'helm-find-files
)
(evil-leader/set-key "p" 'popup-imenu)

(evil-leader/set-key "xE" 'eval-buffer)


(define-key evil-normal-state-map (kbd "j") 'evil-next-visual-line)
(define-key evil-normal-state-map (kbd "k") 'evil-previous-visual-line)

(define-key evil-normal-state-map (kbd "J") (kbd "M-5 j"))
(define-key evil-normal-state-map (kbd "K") (kbd "M-5 k"))
(define-key evil-visual-state-map (kbd "J") (kbd "M-5 j"))
(define-key evil-visual-state-map (kbd "K") (kbd "M-5 k"))

; Moving around
(define-key evil-normal-state-map (kbd "w") 'evil-forward-WORD-begin)
(define-key evil-normal-state-map (kbd "W") 'evil-forward-word-begin)
(define-key evil-normal-state-map (kbd "b") 'evil-backward-WORD-begin)
(define-key evil-normal-state-map (kbd "B") 'evil-backward-word-begin)
(define-key evil-normal-state-map (kbd "e") 'evil-forward-WORD-end)
(define-key evil-normal-state-map (kbd "E") 'evil-forward-word-end)

(define-key evil-visual-state-map (kbd "w") 'evil-forward-WORD-begin)
(define-key evil-visual-state-map (kbd "W") 'evil-forward-word-begin)
(define-key evil-visual-state-map (kbd "b") 'evil-backward-WORD-begin)
(define-key evil-visual-state-map (kbd "B") 'evil-backward-word-begin)
(define-key evil-visual-state-map (kbd "e") 'evil-forward-WORD-end)
(define-key evil-visual-state-map (kbd "E") 'evil-forward-word-end)

; Moving across windows
(evil-leader/set-key "sh" 'split-window-right)
(evil-leader/set-key "sv" 'split-window-below)
(define-key evil-normal-state-map (kbd "M-l") 'evil-window-right)
(define-key evil-normal-state-map (kbd "M-h") 'evil-window-left)
(define-key evil-normal-state-map (kbd "M-k") 'evil-window-up)
(define-key evil-normal-state-map (kbd "M-j") 'evil-window-down)


(with-eval-after-load 'evil-maps
  (define-key evil-motion-state-map (kbd ";") 'evil-ex))
