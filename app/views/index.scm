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

(define-module (app views index)
  #:use-module (ice-9 i18n)
  #:use-module (artanis i18n)
  #:use-module (oculuslambda html)
  #:use-module (oculuslambda query-escape)
  #:use-module (artanis artanis)
  #:use-module (artanis i18n sxml)
  #:use-module (hygguile abstraction)
  #:use-module (hygguile components button)
  #:use-module (artanis i18n locale)
  #:use-module (ice-9 textual-ports)
  #:use-module (ice-9 string-fun))

(define-public (welcome-page rc)
  (let* ((G_ (:i18n rc))
         (welcome-html `((div (p ,(G_
                                   "oculuslambda is written in Lisp (Guile Scheme), leverages SXML, SQLite3, some basic POSIX / UNIX utilities, and the mighty GNU Artanis web-framework."))
                              (p ,(G_
                                   "This is a system monitoring tool, observability, alerting, dashboarding and more, all configurable in Lisp (Guile Scheme)."))))))
    (oculuslambda-html-template G_
                                #:title (format #f "oculuslambda - ~a"
                                                (G_ "welcome to oculuslambda"))
                                #:body welcome-html)))

(define-public (system-detail-list-page rc all-stats)
  (let* ((G_ (:i18n rc))
         (welcome-html `((dl (@ (class ,(->css '(mx-1 my-4 flex flex-col gap-3))))
                             ,(map (lambda (s)
                                     `((div (@ (class ,(->css '(p-2
                                                                bg-stone-300
                                                                shadow-md
                                                                rounded-xl))))
                                            (dt (@ (class ,(->css '(font-bold))))
                                                ,(assoc-ref s "id"))
                                            (dd (@ (class ,(->css '(overflow-auto
                                                                    text-sm
                                                                    p-1 mx-2
                                                                    whitespace-pre
                                                                    font-mono))))
                                                ,(unescape-str (assoc-ref s
                                                                "stat_data"))))))
                                   (assoc-ref all-stats
                                              'fixed-stats))))))
    (oculuslambda-html-template G_
                                #:title (format #f "oculuslambda - ~a"
                                                (G_ "welcome to oculuslambda"))
                                #:body welcome-html)))

(define-public (system-detail-grid-page rc all-stats)
  (let* ((G_ (:i18n rc))
         (numeric-cpu-stat (lambda (s)
                             (string->number (format #f "-~a"
                                                     (string-replace-substring
                                                      (assoc-ref s "stat_data")
                                                      "," ".")))))
         (cpu-data (assoc-ref (assoc-ref all-stats
                                         'timeline-stats)
                              'cpu))
         (first-cpu-moment (assoc-ref (car cpu-data) "updated_at"))
         (last-cpu-moment (assoc-ref (list-ref cpu-data
                                               (- (length cpu-data) 1))
                                     "updated_at"))
         (highest-cpu-moment (apply min
                                    (map numeric-cpu-stat cpu-data)))
         (cpu-view-box (format #f "0 ~a ~a ~a" highest-cpu-moment
                               (- last-cpu-moment first-cpu-moment)
                               (* -1 highest-cpu-moment)))
         (cpu-points (string-join (map (lambda (s)
                                         (format #f "~a,~a"
                                                 (- (assoc-ref s "updated_at")
                                                    first-cpu-moment)
                                                 (numeric-cpu-stat s)))
                                       cpu-data) " "))
         (cpu-html `((div (@ (class ,(->css '(p-2 bg-stone-300 rounded-xl
                                                  shadow-md))))
                          (span (@ (class ,(->css '(font-bold))))
                                ,(G_ "cpu load graph"))
                          (div (svg (@ (viewBox ,cpu-view-box))
                                    (polyline (@ (points ,cpu-points))))))))
         (welcome-html `((div (@ (class ,(->css '(mx-1 my-4
                                                       grid
                                                       grid-cols-1
                                                       sm:grid-cols-1
                                                       md:grid-cols-2
                                                       lg:grid-cols-3
                                                       gap-2))))
                              ,(map (lambda (s)
                                      `((div (@ (class ,(->css '(p-2
                                                                 bg-stone-300
                                                                 shadow-md
                                                                 rounded-xl))))
                                             (span (@ (class ,(->css '(font-bold))))
                                                   ,(assoc-ref s "id"))
                                             (div (@ (class ,(->css '(overflow-auto
                                                                      text-sm
                                                                      p-1 mx-2
                                                                      whitespace-pre
                                                                      font-mono))))
                                                  ,(unescape-str (assoc-ref s
                                                                  "stat_data"))))
                                        
                                        ))
                                    (assoc-ref all-stats
                                               'fixed-stats))))))
    
    (oculuslambda-html-template G_
                                #:title (format #f "oculuslambda - ~a"
                                                (G_ "welcome to oculuslambda"))
                                #:body `((div ,cpu-html
                                              ,welcome-html)))))

