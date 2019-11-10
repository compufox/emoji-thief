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
   :arg-parser #'(lambda (d) (concatenate 'string (string d) "/"))
   :meta-var "DIRECTORY"))

(defun agetf (place indicator)
  "getf but for assoc lists"
  (cdr (assoc indicator place :test #'equalp)))


(defun get-emoji-list (instance)
  "downloads the list of custom emoji for INSTANCE"

  ;; gets our json, and decodes it
  ;; if we error out we alert the user
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
  "download emoji from URI saving it to NAME"

  ;; fetches the emoji,
  ;;  skipping it if it already exists
  ;; and logging the output if *verbose*
  (when (and (fetch uri (concatenate 'string name ".png") :if-exists nil)
	     *verbose*)
    (format t "downloading ~a~%" name)))


(defun download-list (list)
  "download a LIST of emojis"

  ;; clear out our list of failed emojis
  (setf *failed* '())

  ;; for every emoji alist in LIST
  ;;  we try and download it,
  ;; if it errors we shove the alist inside *failed*
  (dolist (emoji list)
    (handler-case (download-emoji (agetf emoji :shortcode) (agetf emoji :url))
      (error ()
	(push emoji *failed*)))))


(defun get-all-emojis (instance)
  "downloads all emojis from INSTANCE"
  (let ((list (get-emoji-list instance))
	(dir (merge-pathnames (or *out-dir* (concatenate 'string instance "/")))))
    
    ;; creates our output directory
    (ensure-directories-exist dir)

    ;; goes into the new folder and starts downloading emojis
    (with-cwd dir
      
      ;; download the initial list
      (download-list list)

      ;; if we're retrying then try the failed ones again
      (when *retry*
	(download-list *failed*))

      ;; print out the shortcodes for all the failed emojis
      (mapcar (lambda (e) (format t "failed to download ~a~%" (agetf e :shortcode)))
	      *failed*)

      ;; print a message saying to rerun if there were still failed emojis
      (unless (zerop (length *failed*))
	(format t "~%run again to download failed emojis~%")))))


(defun steal ()
  "function for the binary to run
parses arguments passed from command line"
  (multiple-value-bind (opts args) (get-opts)
    
    ;; prints help usage if -h/--help/no arguments were given
    (when (or (getf opts :help nil)
	      (every #'null (list opts args)))
      (describe
       :prefix "download all emojis from a mastodon or pleroma server"
       :usage-of "steal"
       :args "DOMAIN-NAME")
      (exit 0))

    ;; sets up our internal variables based off of our command
    ;;  line arguments
    (setf *verbose* (getf opts :verbose nil))
    (setf *retry* (getf opts :retry nil))
    (setf *out-dir* (getf opts :out nil))

    ;; starts downloading all emojis,
    ;;  while also trapping ctrl-c (user-abort)
    (handler-case (with-user-abort
		      (mapcar #'get-all-emojis args))
      (user-abort () (exit 1)))))
