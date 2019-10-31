;;;; emoji thief.lisp

(in-package #:emoji-thief)

(defvar *api-endpoint* "/api/v1/custom_emojis")
(defvar *verbose* nil)
(defvar *failed* '())
(defvar *retry* nil)
(defvar *out-dir* nil)

(define-opts
  (:name :help
   :description "print this help text"
   :short #\h
   :long "help")
  (:name :verbose
   :description "print progress text"
   :short #\v
   :long "verbose")
  (:name :retry
   :description "retry failed downloads"
   :short #\r
   :long "retry")
  (:name :out
   :description "DIRECTORY to put emojis"
   :short #\o
   :long "out"
   :meta-var "DIRECTORY"))

(defun agetf (place indicator)
  "getf but for assoc lists"
  (cdr (assoc indicator place :test #'equalp)))

(defun get-emoji-list (instance)
  (when (starts-with-p "https://" instance)
    (setf instance (substring 9 (length instance) instance)))
  (decode-json-from-string
   (handler-case (get (concatenate 'string
				   (unless (starts-with-p "https://" instance)
				     "https://")
				   instance
				   *api-endpoint*))
     (error ()
       (format t "failed to get emoji list for ~a~%" instance)
       (exit 1)))))

(defun download-emoji (name uri)
  (when (and (fetch uri (concatenate 'string name ".png") :if-exists nil)
	     *verbose*)
    (format t "downloading ~a~%" name)))

(defun download-list (list)
  (labels ((agetf (place indicator) (cdr (assoc indicator place :test #'equalp))))
    (setf *failed* '())
    (dolist (emoji list)
      (handler-case (download-emoji (agetf emoji :shortcode) (agetf emoji :url))
	(error ()
	  (push emoji *failed*))))))

(defun get-all-emojis (instance)
  (let ((list (get-emoji-list instance))
	(dir (merge-pathnames (or *out-dir* (concatenate 'string instance "/")))))
    (ensure-directories-exist dir)
    (with-cwd dir
      (download-list list)
      (when *retry*
	(download-list *failed*))
      (mapcar (lambda (e) (format t "failed to download ~a~%" (agetf e :shortcode)))
	      *failed*)
      (unless (zerop (length *failed*))
	(format t "~%run again to download failed emojis~%")))))

(defun steal ()
  (multiple-value-bind (opts args) (get-opts)
    (when (or (getf opts :help nil)
	      (every #'null (list opts args)))
      (describe
       :prefix "download all emojis from a mastodon or pleroma server"
       :usage-of "steal"
       :args "DOMAIN-NAME")
      (exit 0))
    (setf *verbose* (getf opts :verbose nil))
    (setf *retry* (getf opts :retry nil))
    (setf *out-dir* (getf opts :out nil))
    
    (handler-case (with-user-abort
		      (mapcar #'get-all-emojis args))
      (user-abort () (exit 1)))))
