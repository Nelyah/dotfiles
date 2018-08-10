"Init module for config languages (e.g. Apache, nginx configs)."
(use-package evil
  :demand
  :config (evil-mode 1))

;; (use-package evil-leader
;;   :demand
;;   :config (progn
;;             (setq evil-leader/in-all-states t)
;;             (global-evil-leader-mode)
;;             (evil-leader/set-leader "SPC")))
(setq-default indent-tabs-mode nil)

(define-key evil-normal-state-map (kbd "j") 'evil-next-visual-line)
(define-key evil-normal-state-map (kbd "k") 'evil-previous-visual-line)

(define-key evil-normal-state-map (kbd "J") (kbd "M-5 j"))
(define-key evil-normal-state-map (kbd "K") (kbd "M-5 k"))
(define-key evil-visual-state-map (kbd "J") (kbd "M-5 j"))
(define-key evil-visual-state-map (kbd "K") (kbd "M-5 k"))


(with-eval-after-load 'evil-maps
  (define-key evil-motion-state-map (kbd ";") 'evil-ex))
