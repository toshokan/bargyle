(define-module (bargyle misc))

(use-modules (bargyle sys)
	     (ice-9 regex)
	     (ice-9 threads))

(define-public (make-update-widget mutex table hook)
  (lambda (k v)
    (with-mutex mutex
      (hash-set! table k v))
    (hook)))

(define-public (get-volume)
  (let* ((volume (sys-capture "amixer get Master"))
	 (enabled? (string-contains volume "[on]"))
	 (percentage (string-trim-right
		      (match:substring (car (list-matches "[0-9]*%" volume)))
		      #\%)))
    (if enabled?
	(simple-format #f "~a%" percentage)
	(simple-format #f "~aM" percentage))))
