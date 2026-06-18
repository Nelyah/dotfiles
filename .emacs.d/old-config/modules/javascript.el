;; "Init module for JavaScript (including React/JSX)."

(use-package prettier-js)
(use-package rjsx-mode :mode "\\.jsx?$")

(use-package lsp-javascript-typescript
  :config (progn
            (add-hook 'js-mode-hook #'lsp-javascript-typescript-enable)
            (add-hook 'rjsx-mode #'lsp-javascript-typescript-enable)))
