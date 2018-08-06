;; "Init module for Magit."
(use-package magit
  :config
  (progn
    (global-set-key (kbd "C-x g") 'magit-status)
    (add-to-list 'evil-emacs-state-modes 'magit-mode)
    (add-to-list 'evil-emacs-state-modes 'magit-blame-mode)
    (evil-leader/set-key "g" 'magit-status)))
