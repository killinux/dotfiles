(defmacro require-and-exec (feature &optional &rest body)
  "Require the feature and execute body if it was successfull loaded."
  `(if (require ,feature nil 'noerror)
        (progn ,@body)
    (message (format "%s not loaded" ,feature))))

(defmacro load-and-exec (file &optional &rest body)
  "Load the file and execute body if it was successfull loaded."
  `(if (load ,file t)
        (progn ,@body)
    (message (format "%s not loaded" ,file))))

(defun plasma-send-notification (msg title &optional timeout)
  "Send plasma notification."
  (let* ((timeouts (if timeout (format "%d" timeout)
                     "10"))
         (command (format "kdialog --passivepopup '%s' --title '%s' %s" msg title timeouts)))
    (shell-command-to-string command)))

(defun libnotify-send-notification (msg title &optional timeout urgency)
  "Send libnotify notification."
  (let* ((timeouts (if timeout (format "%d" timeout)
                     "10"))
         (urgencys (if urgency (format "%s" urgency)
                     "normal"))
        (command
             (format "notify-send -u %s -t %s '%s' '%s'" urgencys timeouts title msg)))
    (shell-command-to-string command)))

(defun send-notification (msg title &optional timeout)
  "Sends notification."
  (funcall 'libnotify-send-notification msg title timeout))

(defun x-urgency-hint (frame arg &optional source)
  (let* ((wm-hints (append (x-window-property 
			    "WM_HINTS" frame "WM_HINTS" 
			    (if source
				source
			      (string-to-number 
			       (frame-parameter frame 'outer-window-id)))
			    nil t) nil))
	 (flags (car wm-hints)))
    (setcar wm-hints
	    (if arg
		(logior flags #x00000100)
	      (logand flags #xFFFFFEFF)))
    (x-change-window-property "WM_HINTS" wm-hints frame "WM_HINTS" 32 t)))

(defun add-to-hooks (fun hooks)
  "Add function to hooks"
  (mapc (lambda (hook)
          (add-hook hook fun))
        hooks))

(provide 'cofi-util)
