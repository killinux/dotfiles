(when (require 'ido nil 'noerror)
  (setq ido-enable-regexp t)
  (setq ido-enable-dot-prefix t)
  (setq ido-enable-flex-matching t)
  (setq ido-use-url-at-point t)
  (setq ido-use-filename-at-point t)
  (setq ido-everywhere t)
  (ido-mode t)
  )