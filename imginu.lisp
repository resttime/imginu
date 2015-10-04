(in-package #:imginu)

(defclass booru ()
  ((post-attribs :accessor post-attribs)
   (raw-api :accessor raw-api)))

(defclass gelbooru (booru)
  ((api-url :initform "http://gelbooru.com/index.php?page=dapi&s=post&q=index"
	    :reader api-url)))

(defclass safebooru (gelbooru)
  ((api-url :initform "http://safebooru.org/index.php?page=dapi&s=post&q=index")))

(defmethod raw-posts ((booru safebooru))
  (xmlrep-children (raw-api booru)))

(defun raw-value (attrib raw-post)
  (xmlrep-attrib-value attrib raw-post))

(defun post-count (raw-api)
  (read-from-string (xmlrep-attrib-value "count" raw-api)))

(defun convert-for-web (image)
  (concatenate 'string "data:image/jpg;base64," (usb8-array-to-base64-string image)))

(defmethod fetch ((booru safebooru) &key (tags "") limit pid id cid)
  "Grabs the raw api"
  (setf (raw-api booru)
	(parse (http-request (api-url booru)
			     :parameters `(("limit" . ,(write-to-string limit))
					   ("pid" . ,(write-to-string pid))
					   ("tags" . ,tags)
					   ("cid" . ,(write-to-string cid))
					   ("id" . ,(write-to-string id)))))))

(defmethod wan ((booru safebooru) &key (tags "") (output :b))
  "Fetches a random image from a booru based on the tags. Different keywords for output will alter the format of the image returned."
  (fetch booru :tags tags :limit 0)
  (fetch booru :tags tags :pid (random (post-count (raw-api booru))) :limit 1)
  (let* ((image (http-request (raw-value "sample_url" (first (raw-posts booru))))))
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
