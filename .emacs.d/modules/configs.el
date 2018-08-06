;; "Init module for config languages (e.g. Apache, nginx configs)."
(use-package apache-mode)
(use-package nginx-mode)
(use-package syslog-mode
  :load-path "~/.emacs.d/syslog-mode.el"
  :mode "\\.log$")

(evil-leader/set-key
  "mca" 'apache-mode
  "mcs" 'syslog-mode
  "mcn" 'nginx-mode)
