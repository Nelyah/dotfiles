(use-package company
  :config
    (progn
        (add-hook 'prog-mode-hook #'(lambda () (company-mode)))
        (setq company-show-numbers t)
    (setq company-idle-delay 0)
    (set 'company-auto-complete t)
    (add-hook 'prog-mode-hook 'company-mode)
    (add-hook 'after-init-hook 'global-company-mode)
    (global-company-mode 1))
)
(with-eval-after-load 'company
  (define-key company-active-map (kbd "M-n") nil)
  (define-key company-active-map (kbd "M-p") nil)
  (define-key company-active-map (kbd "C-n") #'company-select-next)
  (define-key company-active-map (kbd "C-p") #'company-select-previous)
  (define-key company-active-map (kbd "SPC") 'company-abort)
)


(use-package company-lsp :config (push 'company-lsp company-backends))

(use-package company-box
  :hook (company-mode . company-box-mode)
  :custom-face
    (company-box-annotation ((t (:inherit company-tooltip-annotation :background "#383c44" :foreground "dim gray"))))
    (company-box-background ((t (:inherit company-tooltip :background "#383c44" :box (:line-width 5 :color "grey75" :style released-button)))))
    (company-box-selection ((t (:inherit company-tooltip-selection :foreground "sandy brown")))))

;; (use-package company-statistics
;;   :config
;;     (add-hook 'after-init-hook 'company-statistics-mode))

(use-package company-anaconda
  :config
  (add-to-list 'company-backends 'company-anaconda)
  (add-hook 'python-mode-hook 'anaconda-mode)
)

;; Standard Jedi.el setting
(add-hook 'python-mode-hook 'jedi:setup)
(setq jedi:complete-on-dot t)

