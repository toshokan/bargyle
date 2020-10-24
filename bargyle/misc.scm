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
  (let* ((volume (string-trim-right (sys-capture "pacmd list-sinks | grep -oP 'volume: front-left: .* \\K[0-9]+(?=%)'")))
	 (sinks (sys-capture "pacmd list-sinks"))
	 (enabled? (string-contains sinks "muted: yes")))
    (if enabled?
	(simple-format #f "~a%" volume)
	(simple-format #f "~aM" volume))))
