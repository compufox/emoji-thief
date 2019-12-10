(in-package :cl-user)
(defpackage #:emoji-thief
  (:nicknames :thief)
  (:use :cl :with-user-abort)
  (:import-from :cl-json
		:decode-json-from-string)
  (:import-from :uiop
		:call-with-current-directory
		:directory-exists-p)
  (:shadowing-import-from :unix-opts
			  :define-opts
			  :get-opts
			  :exit
			  :describe)
  (:import-from :str
		:starts-with-p
		:substring
		:containsp)
  (:shadowing-import-from :dex
			  :get
			  :fetch)
  (:export :get-all-emojis))
