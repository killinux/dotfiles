(defconst startup-time
  (current-time)
  "Time Emacs started.")

(defun cofi/fortune2scratch ()
  "Return a comment-padded fortune cookie."
  (let ((cookie (shell-command-to-string "fortune -a")))
    (concat
     (replace-regexp-in-string " *$" ""
        (replace-regexp-in-string "^" ";; " cookie))
     "\n")))
(setq initial-scratch-message (cofi/fortune2scratch))

(when
    (load
     (expand-file-name "~/.emacs.d/elpa/package.el"))
  (add-to-list 'package-archives '("elpa" . "http://tromey.com/elpa/"))
  (add-to-list 'package-archives '("technomancy" . "http://repo.technomancy.us/emacs/"))
  (package-initialize))

;; (load "~/.elisp/nxhtml/autostart.el")

(mapc (lambda (dir)
             (add-to-list 'load-path dir))
      '(
        "~/.elisp"
        "~/.emacs.d"
        "~/.elisp/vendor/full-ack"
        "~/.elisp/vendor/magit"
        "~/.elisp/vendor/sackspace"
        "~/.elisp/vendor/keychain-environment"
        "~/.elisp/vendor/gist"
        "~/.elisp/vendor/rainbow"
        "~/.elisp/vendor/pylookup"
        "~/.elisp/vendor/scratch"
        "~/.elisp/vendor/offlineimap"
        "~/.elisp/vendor/popwin-el"
        "/usr/local/share/emacs/site-lisp/semi/"
        "/usr/local/share/emacs/site-lisp/flim/"
        "/usr/local/share/emacs/site-lisp/apel/"
        "/usr/local/share/emacs/23.2/site-lisp/emu/"
        "/usr/local/share/emacs/site-lisp/wl/"
        ))

(defvar hostname (car (split-string system-name "\\." t)))
(defvar on-mobile? (find hostname '("hitchhiker") :test #'string=))

(require 'cofi-util)
(require 'cofi-vim)
(load "private" 'noerror)

(mapc #'load '(
            "cofi-autoloads"
            "cofi-anything"
            "cofi-buffer"
            "cofi-calendar"
            "cofi-desktop"
            "cofi-ediff"
            "cofi-mail"
            "cofi-project"
            "cofi-snippets"
            "cofi-ui"
            "cofi-org"
            "cofi-windowing"
            "cofi-completion"
            ))

(defvar cofi/full-emacs t "Load all settings not just minimal.")
(defvar cofi/mail-instance nil "This is an email instance.")

(add-to-list 'command-switch-alist
             '("wl" . (lambda (&rest ignore)
                        (setq cofi/mail-instance t)
                        (setq cofi/full-emacs nil)
                        ;; Exit Emacs after quitting WL
                        (add-hook 'wl-exit-hook 'save-buffers-kill-emacs))))

(add-hook 'emacs-startup-hook (lambda ()
                                (when cofi/mail-instance
                                  (global-linum-mode -1)
                                  (wl)
                                  (add-hook 'emacs-startup-hook 'wl t))
                                (when cofi/full-emacs
                                  (load "cofi-programming"))
                                ))

(load-theme 'cofi-dark)
(cofi-file-standard)

(message "Time needed to load: %d seconds."
         (time-to-seconds (time-since startup-time)))
