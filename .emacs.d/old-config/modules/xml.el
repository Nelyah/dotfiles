;; "Init module for XML. Adds helper functions and tag folding."
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
  "h" 'hs-toggle-hiding)
