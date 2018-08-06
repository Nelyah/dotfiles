;; "Init module to support JSON syntax highlighting/navigation/formatting."
(use-package json-mode :mode "\\.json")
(use-package json-navigator)
(use-package json-reformat)

(evil-leader/set-key-for-mode 'json-mode
  "jnp" 'json-navigator-navigate-after-point
  "jnr" 'json-navigator-navigate-region
  "jr" 'json-reformat-region
  "jpr" 'json-pretty-print
  "jpb" 'json-pretty-print-buffer)
