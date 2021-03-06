(require 'cl-lib)

;; setup for ipython 0.11
(setq python-shell-interpreter "ipython"
      python-shell-interpreter-args ""
      python-shell-prompt-regexp "In \\[[0-9]+\\]: "
      python-shell-prompt-output-regexp "Out\\[[0-9]+\\]: "
      python-shell-completion-setup-code "from IPython.core.completerlib import module_completion"
      python-shell-completion-module-string-code "';'.join(module_completion('''%s'''))\n"
      python-shell-completion-string-code "';'.join(get_ipython().Completer.all_completions('''%s'''))\n")

(require-and-exec 'flymake
  (defun flymake-pylint-init ()
    (let* ((temp-file (flymake-init-create-temp-buffer-copy
                       'flymake-create-temp-inplace))
           (local-file (file-relative-name
                        temp-file
                        (file-name-directory buffer-file-name))))
      (list "epylint" (list local-file))))

  (add-to-list 'flymake-allowed-file-name-masks
               '("\\.pyw?\\'" flymake-pylint-init)))

;; Folding
(add-hook 'python-mode-hook 'hs-minor-mode)

;; setup pymacs
(autoload 'pymacs-apply "pymacs")
(autoload 'pymacs-call "pymacs")
(autoload 'pymacs-eval "pymacs" nil t)
(autoload 'pymacs-exec "pymacs" nil t)
(autoload 'pymacs-load "pymacs" nil t)

(defkeymap cofi-rope-map
  "u"     'rope-undo
  "C-r"   'rope-redo

  "C-f"   'rope-find-file
  "4 C-f" 'rope-find-file
  "O"     'rope-open-project
  "C"     'rope-close-project

  "D"     'rope-get-doc
  "d"     'rope-show-calltip

  "a"     'rope-auto-import
  "i"     'rope-organize-imports
  "A"     'rope-analyze-modules

  "f"     'rope-find-occurrences
  "F"     'rope-find-implementations
  "TAB"   'rope-extended-completions

  "r"     'rope-rename
  "c"     'rope-change-signature)

;; setup ropemacs
(setq ropemacs-enable-autoimport t
      ropemacs-autoimport-modules '( "os"
                                     "os.path"
                                     "sys"
                                     "itertools"
                                     "operator"
                                    )
      ropemacs-max-doc-buffer-height 40
      ropemacs-local-prefix nil
      ropemacs-global-prefix nil
      ropemacs-guess-project t
      ropemacs-separate-doc-buffer nil
      ropemacs-enable-shortcuts nil)

(defadvice rope-open-project (after cofi-analyze-after-open activate)
  (rope-analyze-modules))


;; based on https://bitbucket.org/birkenfeld/dotemacs/src/tip/auto-complete-python.el
(defvar ac-ropemacs-docs nil)
(defun ac-ropemacs-candidates ()
  (setq ac-ropemacs-docs nil)
  (loop for (name doc _) in (rope-extended-completions)
        for ac-name = (concat ac-prefix name)
        do (when (push (cons ac-name doc) ac-ropemacs-docs))
        collect ac-name))

(defun ac-ropemacs-document (name)
  (assoc-default name ac-ropemacs-docs))

(defun ac-ropemacs-available ()
  (locate-dominating-file buffer-file-name ".rope"))

(ac-define-source nropemacs
  '((candidates . ac-ropemacs-candidates)
    (symbol     . "p")
    (document   . ac-ropemacs-document)
    (cache      . t)
    (available .  ac-ropemacs-available)))

(ac-define-source nropemacs-dot
  '((candidates . ac-ropemacs-candidates)
    (symbol     . "p")
    (document   . ac-ropemacs-document)
    (cache      . t)
    (prefix     . c-dot)
    (requires   . 0)
    (available . ac-ropemacs-available)))

(cl-loop for f in '(python-shell-send-region
                    python-shell-send-defun
                    python-shell-send-string)
         do (declare-function f "python.el"))

(defun cofi/python-send-dwim (arg)
  "Send region if region is active and current defun else."
  (interactive "p")
  (if (region-active-p)
      (python-shell-send-region (region-beginning) (region-end))
    (python-shell-send-defun arg)))

(defun cofi/python-send-statement ()
  "Send current-line without whitespace to inferior shell."
  (interactive)
  (python-shell-send-string (buffer-substring-no-properties
                             (save-excursion (python-nav-beginning-of-statement)
                                             (point))
                             (save-excursion (python-nav-end-of-statement)
                                             (point)))))

(require 'elpy)

(add-all-to-hook 'python-mode-hook
                 #'show-paren-mode
                 #'auto-fill-mode
                 (lambda ()
                   (setq tab-width 4)
                   (setq mode-name "py"))
                 (gen-local-fill-keymap-hook
                     "C-c p"     cofi-rope-map
                     "C-c C-d"   #'elpy-doc
                     "C-c ?"     #'pylookup-lookup
                     "C-c C-r"   #'elpy-refactor
                     "C-c C-t"   #'elpy-test
                     "C-c C-c"   #'cofi/python-send-dwim
                     "C-c C-l"   #'cofi/python-send-statement
                     "C-c C-f"   #'python-shell-send-file
                     "C-c C-e"   #'python-eldoc-at-point
                     "C-c C-b"   #'python-shell-send-buffer)
                 )

(setq pylookup-db-file (cofi/var-file "pylookup.db")
      pylookup-html-locations '("~/doc/python-2.7/")
      pylookup-completing-read #'helm-completing-read-default)

;;; load ropemacs
(add-all-to-hook 'python-mode-hook
          #'(lambda ()
              (pymacs-load "ropemacs" "rope-"))
          ;; move useful global commands to local keymap
          (gen-local-fill-keymap-hook
           "M-?"   'rope-code-assist
           "C-M-?" 'rope-lucky-assist
           ))

(add-to-loadpath "~/.elisp/vendor/emacs-jedi/")
(require-and-exec 'jedi
  (add-hook 'python-mode-hook #'jedi:setup)
  (fill-keymap jedi-mode-map
    "C-c d" #'jedi:show-doc
    "C-c t" #'jedi:get-in-function-call
    "C-c g" #'jedi:goto-definition))

(add-hook 'python-mode-hook
          (lambda () (setq header-line-format '((t (:eval (which-function)))))))

(require-and-exec 'pydoc-info
  (require 'info-look)
  (info-lookup-add-help
   :mode 'python-mode
   :parse-rule 'pydoc-info-python-symbol-at-point
   :doc-spec
   '(("(python)Index" pydoc-info-lookup-transform-entry)
     ("(sphinx)Index" pydoc-info-lookup-transform-entry))))

(provide 'cofi-python)
