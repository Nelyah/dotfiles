;; "Init module for Magit."
(use-package magit
  :config
  (progn
    (global-set-key (kbd "C-x g") 'magit-status)
    (add-to-list 'evil-emacs-state-modes 'magit-mode)
    (add-to-list 'evil-emacs-state-modes 'magit-blame-mode)
    (evil-leader/set-key "g" 'magit-status)))

;; full screen magit-status
(defadvice magit-status (around magit-fullscreen activate)
  (window-configuration-to-register :magit-fullscreen)
  ad-do-it
  (delete-other-windows))

;; Restore windows after exiting magit
(defun magit-quit-session ()
  "Restores the previous window configuration and kills the magit buffer"
  (interactive)
  (kill-buffer)
  (jump-to-register :magit-fullscreen))

(use-package magit
  :defer 2
  :diminish magit-auto-revert-mode
  :config
  (add-to-list 'evil-emacs-state-modes 'magit-mode)
  (add-to-list 'evil-emacs-state-modes 'magit-blame-mode)
  )
