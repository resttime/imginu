(in-package #:cl-user)
(asdf:defsystem imginu
    :description "The solution to your booru needs"
    :version "0.0.1"
    :author "resttime"
    :serial t
    :components ((:file "package")
		 (:file "imginu"))
    :depends-on (:drakma
		 :xmls
		 :cl-base64))
