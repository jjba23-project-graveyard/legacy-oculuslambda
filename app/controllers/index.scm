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
        (fibers)
        (fibers channels)
        (ice-9 match)
        (oculuslambda process))

(define (get-uptime)
  (syscall-silent "uptime"))

(define (get-uname)
  (syscall-silent "uname -a"))

(define (get-hostname)
  (syscall-silent "hostname"))

(define (get-mem)
  (syscall-silent "free -h"))

(define (get-disk)
  (syscall-silent "df -h"))

(define (get-part)
  (syscall-silent "lsblk"))

(get "/"
     #:i18n '(cookie "lang")
     #:mime 'xml
     (lambda (rc)
       (let* ((state `()))
         (run-fibers (lambda ()
                       (spawn-fiber (lambda ()
                                      (set! state
                                            (cons `(hostname ,(get-hostname))
                                                  state))))
                       (spawn-fiber (lambda ()
                                      (set! state
                                            (cons `(uptime ,(get-uptime))
                                                  state))))
                       (spawn-fiber (lambda ()
                                      (set! state
                                            (cons `(uname ,(get-uname)) state))))
                       (spawn-fiber (lambda ()
                                      (set! state
                                            (cons `(memory ,(get-mem)) state))))
                       (spawn-fiber (lambda ()
                                      (set! state
                                            (cons `(partitioning ,(get-part))
                                                  state))))
                       (spawn-fiber (lambda ()
                                      (set! state
                                            (cons `(disk-space ,(get-disk))
                                                  state)))))
                     #:drain? #t)
         (response-emit (:mime rc
                               (dashboard-page rc state))))))
