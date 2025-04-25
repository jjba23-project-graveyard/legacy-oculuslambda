;;; oculuslambda - the eye into the system's functioning

;; Copyright © "Josep Bigorra" known as "jjba23" <jjbigorra@gmail.com>

;; oculuslambda is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; oculuslambda is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with oculuslambda.  If not, see <https://www.gnu.org/licenses/>.

(define-artanis-controller index)

(import (web uri)
        (artanis i18n)
        (artanis i18n locale)
        (app views index)
        (oculuslambda html)
        (app models stat)
        (app models time_stat)
        (oculuslambda metrics)
        (fibers)
        (fibers channels)
        (ice-9 match)
        (oculuslambda process))

(get "/"
     #:i18n '(cookie "lang")
     #:mime 'xml
     (lambda (rc)
       (response-emit (:mime rc
                             (welcome-page rc)))))

(define (get-all-stats rc)
  (let* ((stats ($stat 'get))
         (time-stats ($time_stat 'get #:order-by "updated_at ASC"))
         (cpu-stats (filter (lambda (s)
                              (equal? "cpu"
                                      (assoc-ref s "id"))) time-stats))
         (mem-stats (filter (lambda (s)
                              (equal? "mem"
                                      (assoc-ref s "id"))) time-stats))
         (all-stats `((fixed-stats unquote stats)
                      (timeline-stats (cpu unquote cpu-stats)
                                      (mem unquote mem-stats)))))
    all-stats))

(get "/dashboard/system-detail-grid"
     #:i18n '(cookie "lang")
     #:mime 'xml
     (lambda (rc)
       (response-emit (:mime rc
                             (system-detail-grid-page rc
                                                      (get-all-stats rc))))))

(get "/dashboard/system-detail-list"
     #:i18n '(cookie "lang")
     #:mime 'xml
     (lambda (rc)
       (response-emit (:mime rc
                             (system-detail-list-page rc
                                                      (get-all-stats rc))))))
