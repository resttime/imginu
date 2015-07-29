(in-package :cl-user)
(defpackage imginu
  (:use :cl)
  (:import-from :drakma
		:http-request)
  (:import-from :xmls
		:parse
		:xmlrep-attrib-value
		:xmlrep-children)
  (:import-from :cl-base64
		:usb8-array-to-base64-string)
  (:export :wan
	   :display-image))
(in-package :imginu)

(defclass <booru> ()
  ((valid-attribs :accessor valid-attribs)
   (raw-api :accessor raw-api)))

(defclass <gelbooru> (<booru>)
  ((api-url :initform "http://gelbooru.com/index.php?page=dapi&s=post&q=index"
	    :accessor api-url)))

(defclass <safebooru> (<gelbooru>)
  ((api-url :initform "http://safebooru.org/index.php?page=dapi&s=post&q=index")))

(defmethod initialize-instance :after ((this <safebooru>) &key)
  (fetch this :limit 1)
  (let ((post-attribs (cadr (first (raw-posts this)))))
    (setf (valid-attribs this)
	  (loop for (a b) in post-attribs
	     collect a))))

(defmethod raw-posts ((this <safebooru>))
  (xmlrep-children (raw-api this)))

(defun raw-value (attrib raw-post)
  (xmlrep-attrib-value attrib raw-post))

(defun convert-for-web (image)
  (concatenate 'string "data:image/jpg;base64," (usb8-array-to-base64-string image)))

(defmethod fetch ((this <safebooru>) &key (tags "") (limit nil) (pid nil)
				       (id nil) (cid nil))
  (setf (raw-api this)
	(parse (http-request (api-url this)
			     :parameters `(("limit" . ,(write-to-string limit))
					   ("pid" . ,(write-to-string pid)) 
					   ("tags" . ,tags)
					   ("cid" . ,(write-to-string cid))
					   ("id" . ,(write-to-string id)))))))

(defmethod wan ((this <safebooru>) &key (tags "") (output :b))
  "Fetches a random image."
  (fetch this :tags tags)
  (let ((image (http-request (raw-value "sample_url"
					(nth  (random (length (raw-posts this)))
					     (raw-posts this))))))
    (ecase output
      ((:w :web) (convert-for-web image))
      ((:b64 :base64) (usb8-array-to-base64-string image))
      ((:b :binary) image))))

(defun display-image (image)
  "Displays an image in your REPL. Code must be added to ~/.emacs for this to work."
  (let ((image-base64 (usb8-array-to-base64-string image)))
    (handler-case (swank:eval-in-emacs `(slime-media-insert-image-base64
					 ,image-base64
					 " "))
      (error () (print "Could not display image.")))))
