;;; Summary: Python module
(use-package pyvenv)
(use-package lsp-python
  :config (add-hook 'python-mode-hook 'lsp-python-enable))
