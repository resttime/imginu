(defsystem imginu
    :description "Interacts with the various booru type imageboards."
    :depends-on (uiop drakma xmls cl-base64)
    :serial t
    :components
    ((:module "src"
	      :components
	      ((:file "imginu")
	       (:file "ui")))))
