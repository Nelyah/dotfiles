(defun find-init-file ()
  (interactive)
  (find-file "~/.emacs.d/init.el")
)

(defun enable-line-numbers ()
  (setq display-line-numbers t))
