(in-package #:cl-user)
(defpackage imginu
  (:use #:cl #:drakma #:xmls #:cl-base64)
  (:export #:wan
	   #:display-image
	   #:safebooru))
