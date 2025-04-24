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
        (oculuslambda metrics)
        (fibers)
        (fibers channels)
        (ice-9 match)
        (oculuslambda process))


(get "/"
     #:i18n '(cookie "lang")
     #:mime 'xml
     (lambda (rc)
       (let* ((stats ($stat 'get)))
         (response-emit (:mime rc
                         (dashboard-page rc stats))))))
