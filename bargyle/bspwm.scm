(define-module (bargyle bspwm))

(use-modules (bargyle sys)
	     (bargyle bar)
	     (ice-9 regex))

(define (monitor-name monitor-event)
  (substring monitor-event 1))

(define (monitor-widget m)
  (define (markup fg bg)
    ((make-mu m) fg bg "bspc monitor -f ~a"))
  (case (string-ref m 0)
    ((#\M)
     (markup #:focused-monitor-fg #:focused-monitor-bg))
    ((#\m)
     (markup #:monitor-fg #:monitor-bg))
    (else #f)))

(define (seq start end)
  (let loop ((l (list end))
	     (next (1- end)))
    (if (eqv? next start)
	(cons next l)
	(loop (cons next l) (1- next)))))
  
(define (event-widget e idx monitor)
  (define (markup fg bg)
    ((make-mu e) fg bg "bspc desktop -f ~a\\:^~a" monitor idx))
  (case (string-ref e 0)
    ((#\O)
     (markup #:focused-occupied-fg #:focused-occupied-bg))
    ((#\o)
     (markup #:occupied-fg #:occupied-bg))
    ((#\F)
     (markup #:focused-free-fg #:focused-free-bg))
    ((#\f)
     (markup #:free-fg #:free-bg))
    ((#\U)
     (markup #:focused-urgent-fg #:focused-urgent-bg))
    ((#\u)
     (markup #:urgent-fg #:urgent-bg))
    (else #f)))

(define (split-monitors report)
   (map match:substring
	(list-matches "M([^:]|:[^mM])*" report)))

(define (parse-monitor-desktops events)
  (let* ((events (string-split events #\:))
	 (name (monitor-name (car events)))
	 (monitor (monitor-widget (car events))))
    (let loop ((reported '())
	       (desktops (cdr events))
	       (indices (seq 1 (length events))))
      (if (null? desktops)
	  (string-join (cons monitor (reverse! (filter identity reported))) "")
	  (loop (cons (event-widget (car desktops) (car indices) name)
		      reported)
		(cdr desktops)
		(cdr indices))))))

(define-public (parse-report report)
  (let ((monitors (split-monitors report)))
    (map parse-monitor-desktops monitors)))
