;; "Init module for Java."
(use-package lsp-java
  :config (progn
            (add-hook 'java-mode-hook (lambda () (add-to-list 'lsp-java--workspace-folders (lsp-java--get-root))))
            (add-hook 'java-mode-hook 'lsp-java-enable)))
(use-package maven-test-mode)
