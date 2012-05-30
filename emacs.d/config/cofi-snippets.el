(add-to-loadpath "~/.elisp/vendor/yasnippet")
(setq yas/prompt-functions '(yas/ido-prompt
                             yas/completing-prompt))
(setq yas/snippet-dirs '("~/.yasnippets" "~/dev/snippets"))
(require-and-exec 'yasnippet
    (yas/initialize)
    (yas/load-directory "~/.yasnippets")
    (yas/load-directory "~/dev/snippets")
    (setq yas/also-auto-indent-first-line nil)
    (setq yas/indent-line 'fixed)
    (setq yas/fallback-behavior 'call-other-command)
    (setq yas/triggers-in-field t)
    (setq yas/verbosity 2)
    (setq-default yas/trigger-key "SPC"))

(define-key yas/minor-mode-map "\C-c&" nil)

(defun yas/org-very-safe-expand ()
  (let ((yas/fallback-behavior 'return-nil)) (yas/expand)))

(make-variable-buffer-local 'yas/trigger-key)
(add-hook 'org-mode-hook
          (lambda ()
            ;; yasnippet (using the new org-cycle hooks)
            (add-to-list 'org-tab-first-hook 'yas/org-very-safe-expand)
            (define-key yas/keymap [tab] 'yas/next-field)))

(defun cofi/no-yas ()
  (setq yas/dont-activate t))

(add-to-hooks 'cofi/no-yas '(magit-mode-hook
                            calc-mode-hook))

(defun cofi/region-to-snippet (begin end)
  "Write new snippet based on current region."
  (interactive "r")
  (let ((region (buffer-substring begin end)))
    (yas/new-snippet)
    (save-excursion
      (goto-char (point-max))
      (insert region))))

(provide 'cofi-snippets)
