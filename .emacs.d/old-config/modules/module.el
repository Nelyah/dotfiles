(defvar init-modules-defs-plist nil
  "The module definitions plist.")

(defgroup init-modules nil
  "The init modules customization group.")

(defun init-module-load (name)
  "Load the module NAME."
  (let ((exec-module (plist-get init-modules-defs-plist name)))
    (message "Init-module-load %s: %s" name exec-module)
    (when exec-module
      (message "Found def for %s" name)
      (funcall exec-module))))

(defun init-module-set (name value)
  "Enable/disable the module NAME by setting boolean VALUE."
  (set-default name value)
  (when value
    (message "%s set: evaluating" name)
    (init-module-load name)))

(defmacro defmodule (name doc &rest body)
  "Define an init module called NAME that executes BODY when enabled."
  (message "Defining module for %s" name)
  (let ((module-name (intern (format "init-module-%s" name))))
    ;; Declare var if not already
    (when (not (boundp module-name))
      (custom-declare-variable module-name nil
                               doc
                               :group 'init-modules
                               :set 'init-module-set
                               :tag (symbol-name name)
                               :type '(boolean)))
    `(progn
       ;; Stash the definition in the symbol's plist
       (setq init-modules-defs-plist
             (plist-put init-modules-defs-plist
                        (quote ,module-name)
                        (lambda ()
                          (progn
                            (message "Evaluating definition of %s" ,module-name)
                            ,@body))))
       ;; If set, evaluate it
       (when ,module-name
         (message "Evaluating %s on first def" (quote ,module-name))
         ,@body))))



(defmodule java
  "Init module for Java."
  (use-package lsp-java
    :config (progn
              (add-hook 'java-mode-hook (lambda () (add-to-list 'lsp-java--workspace-folders (lsp-java--get-root))))
              (add-hook 'java-mode-hook 'lsp-java-enable)))
  (use-package maven-test-mode))


(defmodule sql
  "Init module for SQL. Sets evil leader shortcuts for interpreters."
  (evil-leader/set-key
    "s q p" 'sql-postgres
    "s q s" 'sql-sqlite))


(defmodule docker
  "Init module for working with Docker and Compose."
  (use-package docker)
  (use-package docker-compose-mode)
  (use-package dockerfile-mode :mode "Dockerfile$"))


(defmodule php
  "Init module for php. Uses web-mode for Cake templates."
  (use-package php-mode :mode "\\.php$")
  (use-package web-mode :mode "\\.ctp$"))


(use-package csv-mode)


(defmodule json
  "Init module to support JSON syntax highlighting/navigation/formatting."
  (use-package json-mode :mode "\\.json")
  (use-package json-navigator)
  (use-package json-reformat)

  (evil-leader/set-key-for-mode 'json-mode
    "jnp" 'json-navigator-navigate-after-point
    "jnr" 'json-navigator-navigate-region
    "jr" 'json-reformat-region
    "jpr" 'json-pretty-print
    "jpb" 'json-pretty-print-buffer))


(defmodule xml
  "Init module for XML. Adds helper functions and tag folding."
  (defun split-xml-lines ()
    (interactive)
    ;; TODO use looking-at etc. because replace-regexp is interactive
    (replace-regexp "> *<" ">\n<"))

  (require 'hideshow)
  (require 'sgml-mode)
  (require 'nxml-mode)

  (add-to-list 'hs-special-modes-alist
               '(nxml-mode
                 "<!--\\|<[^/>]*[^/]>"
                 "-->\\|</[^/>]*[^/]>"

                 "<!--"
                 sgml-skip-tag-forward
                 nil))

  (add-hook 'nxml-mode-hook 'hs-minor-mode)

  (evil-leader/set-key-for-mode 'nxml-mode
    "h" 'hs-toggle-hiding))


(defmodule yaml
  "Init module for YAML support."
  (use-package yaml-mode :mode "\\.ya?ml"))


(defmodule configs
  "Init module for config languages (e.g. Apache, nginx configs)."
  (use-package apache-mode)
  (use-package nginx-mode)
  (use-package syslog-mode
    :load-path "~/.emacs.d/syslog-mode.el"
    :mode "\\.log$")

  (evil-leader/set-key
    "mca" 'apache-mode
    "mcs" 'syslog-mode
    "mcn" 'nginx-mode))


(use-package markdown-mode
  :mode "\\.md$")


(defmodule magit
  "Init module for Magit."
  (use-package magit
    :config
    (progn
      (global-set-key (kbd "C-x g") 'magit-status)
      (add-to-list 'evil-emacs-state-modes 'magit-mode)
      (add-to-list 'evil-emacs-state-modes 'magit-blame-mode)
      (evil-leader/set-key "g" 'magit-status))))
