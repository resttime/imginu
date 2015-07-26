# imginu

**imginu** is a *Common Lisp* library that will fetch images from booru imageboards for you.

Usage
-----

```cl
(wan (make-instance '<safebooru>) :tags "inubashiri_momiji")
(display-image (wan (make-instance '<safebooru>) :tags "inubashiri_momiji"))
```

Add to .emacs to display images in the SLIME REPL
-------------------------------------------------

```cl
;---------------------------
; Displaying images in REPL
;---------------------------

; If you already have slime-setup, just add slime-media to the list
(slime-setup '(slime-fancy slime-media))

; Allows SLIME to run code in emacs
(setq slime-enable-evaluate-in-emacs t)

; Function that displays the image by taking in a base64 string
(defun slime-media-insert-image-base64 (base64-string &optional image-words)
  (let ((image-type (image-type-from-data base64-string))
	(image-words (if (or (string= image-words "")
			     (eq image-words nil))
			 " "
		       image-words)))
    (slime-media-insert-image (create-image (base64-decode-string base64-string)
					    image-type t)
			      image-words)))
```