(define-module (bargyle sys))

(use-modules (ice-9 popen)
	     (ice-9 textual-ports)
	     (ice-9 rdelim))

(define-public (map-cmd-lines cmd f)
  (let loop ((port (open-input-pipe cmd)))
    (f (read-line port))
    (loop port)))

(define-public (on-interval s f)
  (f)
  (sleep s)
  (on-interval s f))

(define-public (sys-capture cmd)
  (let ((port (open-input-pipe cmd)))
    (get-string-all port)))

(define-public (interval-cmd cmd s f)
  (on-interval s (lambda () (f (sys-capture cmd)))))
