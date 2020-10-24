(define-module (bargyle misc))

(use-modules (bargyle sys)
	     (ice-9 regex))

(define-public (get-volume)
  (let* ((volume (sys-capture "amixer get Master"))
	 (enabled? (string-contains volume "[on]"))
	 (percentage (string-trim-right
		      (match:substring (car (list-matches "[0-9]*%" volume)))
		      #\%)))
    (if enabled?
	(simple-format #f "~a%" percentage)
	(simple-format #f "~aM" percentage))))
