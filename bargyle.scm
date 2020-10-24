#!/usr/bin/guile -s
!#

(add-to-load-path (dirname (current-filename)))

(use-modules (bargyle sys)
	     (bargyle bspwm)
	     (bargyle misc)
	     (ice-9 futures)
	     (ice-9 threads)
	     (ice-9 regex))

(define m (make-mutex))
(define widgets (make-hash-table))

(define (bar-format)
  (display (simple-format #f "%{l}~a%{c}~a%{r}~a | ~a\n"
			  (hash-ref widgets #:bspc "")
			  (hash-ref widgets #:title "")
			  (hash-ref widgets #:volume (get-volume))
			  (hash-ref widgets #:date )))
  (flush-all-ports))

(define uw (make-update-widget m widgets bar-format))

(define work (list
	      (future (map-cmd-lines "bspc subscribe" (lambda (line)
							(uw #:bspc (string-join (parse-report line) "")))))
	      (future (map-cmd-lines "xtitle -s" (lambda (line)
						   (uw #:title line))))
	      (future (on-interval 1 (lambda ()
				       (uw #:date (strftime "%d %b %H:%M " (localtime (current-time)))))))
	      (future (map-cmd-lines "pactl subscribe" (lambda (line)
							(when (string-match "'change' on client" line)
							  (uw #:volume (get-volume))))))))

(for-each touch work)
