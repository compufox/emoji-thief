;;;; emoji thief.asd

(asdf:defsystem #:emoji-thief
  :description "steal emojis from mastodon/pleroma servers"
  :author "ava fox"
  :license  "NPLv1+"
  :version "1.0"
  :serial t
  :depends-on (#:dexador #:cl-cwd #:str #:cl-json #:unix-opts #:with-user-abort)
  :components ((:file "package")
               (:file "emoji-thief"))
  :build-operation "program-op"
  :build-pathname "bin/steal"
  :entry-point "emoji-thief::steal")
