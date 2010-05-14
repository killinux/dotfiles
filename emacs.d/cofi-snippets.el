(require-and-exec 'yasnippet
    (yas/initialize)
    (yas/load-directory "~/.emacs.d/snippets")
    (setq yas/prompt-functions '(yas/ido-prompt
                                 yas/completing-prompt))
    (setq yas/fallback-behavior '(apply smart-tab))
    (setq yas/also-auto-indent-first-line t)

    (global-set-key (kbd "M-RET") 'yas/expand)
    )

(provide 'cofi-snippets)
