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
         (welcome-html `((div (@ (class ,(->css '(my-6 flex flex-col gap-3
                                                       rounded-xl p-3))))
                              (p (@ (class ,(->css '(text-lg font-bold
                                                             text-stone-300
                                                             max-w-prose))))
                                 ,(G_
                                   "oculuslambda is written in Lisp (Guile Scheme), using SXML, SQLite3, basic POSIX / UNIX utilities, and the mighty GNU Artanis web-framework."))
                              (p (@ (class ,(->css '(text-lg font-bold
                                                             text-stone-300
                                                             max-w-prose))))
                                 ,(G_
                                   "This is a system monitoring tool, observability, alerting, dashboarding and more, all configurable in Lisp (Guile Scheme)."))))))
    (oculuslambda-html-template G_
                                #:title (format #f "oculuslambda - ~a"
                                                (G_ "welcome to oculuslambda"))
                                #:body welcome-html)))

(define* (make-graph-box #:key title view-box points polygon-edges)
  `((div (@ (class ,(->css '(p-3 bg-black rounded-xl shadow-md))))
         (span (@ (class ,(->css '(font-bold text-stone-400))))
               ,title)
         (div (@ (class ,(->css '(my-4 mx-2 overflow-auto))))
              (svg (@ (class ,(->css '(min-h-36)))(viewBox ,view-box))
                   (polygon (@ (class ,(->css '(chart-area)))
                               (points ,(format #f "~a ~a" points (string-join polygon-edges " ")))))
                   (polyline (@ (class ,(->css '(chart-line)))
                                (points ,points))))))))

(define-public (system-detail-grid-page rc all-stats)
  (let* ((G_ (:i18n rc))
         ;; transformations to perform arithmetic on the raw stats
         (numeric-cpu-stat (lambda (s)
                             (string->number (format #f "-~a"
                                                     (string-replace-substring
                                                      (assoc-ref s "stat_data")
                                                      "," ".")))))
         (numeric-mem-stat (lambda (s)
                             (string->number (format #f "-~a"
                                                     (cadr (string-split (assoc-ref
                                                                          s
                                                                          "stat_data")
                                                                         #\space))))))
         ;; filter data from joined stats into per-id
         (cpu-data (assoc-ref (assoc-ref all-stats
                                         'timeline-stats)
                              'cpu))
         (mem-data (assoc-ref (assoc-ref all-stats
                                         'timeline-stats)
                              'mem))
         ;; determine timeline first and last moments for graph scaling
         (first-cpu-moment (assoc-ref (car cpu-data) "updated_at"))
         (last-cpu-moment (assoc-ref (list-ref cpu-data
                                               (- (length cpu-data) 1))
                                     "updated_at"))
         (first-mem-moment (assoc-ref (car mem-data) "updated_at"))
         (last-mem-moment (assoc-ref (list-ref mem-data
                                               (- (length mem-data) 1))
                                     "updated_at"))
         ;; determine peak numbers for graph scaling
         (highest-cpu-moment (apply min
                                    (map numeric-cpu-stat cpu-data)))
         (highest-mem-moment (apply min
                                    (map numeric-mem-stat mem-data)))
         ;; define svg view boxes
         (cpu-view-box (format #f "0 ~a ~a ~a" highest-cpu-moment
                               (- last-cpu-moment first-cpu-moment)
                               (* -1 highest-cpu-moment)))
         (mem-view-box (format #f "0 ~a ~a ~a" highest-mem-moment
                               (- last-mem-moment first-mem-moment)
                               (* -1 highest-mem-moment)))
         ;; convert the data points into svg points
         (cpu-points (string-join (map (lambda (s)
                                         (format #f "~a,~a"
                                                 (- (assoc-ref s "updated_at")
                                                    first-cpu-moment)
                                                 (numeric-cpu-stat s)))
                                       cpu-data) " "))
         (mem-points (string-join (map (lambda (s)
                                         (format #f "~a,~a"
                                                 (- (assoc-ref s "updated_at")
                                                    first-mem-moment)
                                                 (numeric-mem-stat s)))
                                       mem-data) " "))
         ;; join in html
         (cpu-html (make-graph-box #:title (G_ "cpu load graph")
                                   #:view-box cpu-view-box
                                   #:points cpu-points
                                   #:polygon-edges (list (format #f "~a,~a"
                                                                 (-
                                                                  last-cpu-moment
                                                                  first-cpu-moment)
                                                                 (* -1
                                                                    highest-cpu-moment))
                                                         (format #f "0,~a"
                                                                 (* -1
                                                                    highest-cpu-moment)))))
         (mem-html (make-graph-box #:title (G_ "memory usage graph")
                                   #:view-box mem-view-box
                                   #:points mem-points
                                   #:polygon-edges (list (format #f "~a,~a"
                                                                 (-
                                                                  last-mem-moment
                                                                  first-mem-moment)
                                                                 (* -1
                                                                    highest-mem-moment))
                                                         (format #f "0,~a"
                                                                 (* -1
                                                                    highest-mem-moment)))))
         ;; fixed stats
         (more-html `((div (@ (class ,(->css '(mx-1 my-4
                                                    flex
                                                    flex-row
                                                    flex-wrap
                                                    justify-left
                                                    gap-3))))
                           ,(map (lambda (s)
                                   `((div (@ (class ,(->css '(p-3 bg-black
                                                                  shadow-md
                                                                  rounded-xl))))
                                          (span (@ (class ,(->css '(font-bold
                                                                    text-stone-400))))
                                                ,(assoc-ref s "id"))
                                          (div (@ (class ,(->css '(overflow-auto
                                                                   text-sm
                                                                   text-stone-300
                                                                   p-1
                                                                   mx-2
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
                                #:body `((div (div (@ (class ,(->css '(flex
                                                                       flex-col
                                                                       gap-3))))
                                                   ,cpu-html
                                                   ,mem-html)
                                              ,more-html)))))

