;; "Init module for config languages (e.g. Apache, nginx configs)."
(use-package apache-mode)
(use-package nginx-mode)
(use-package syslog-mode
  :load-path "~/.emacs.d/syslog-mode.el"
  :mode "\\.log$")
