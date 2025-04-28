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

(define* (make-card #:key title stat-data)
  `((div (@ (class ,(->css '(p-3 bg-black shadow-md rounded-xl))))
         (span (@ (class ,(->css '(font-bold text-stone-400))))
               ,title)
         (div (@ (class ,(->css '(overflow-auto text-sm
                                                text-stone-300
                                                p-1
                                                mx-2
                                                whitespace-pre
                                                font-mono))))
              ,stat-data))))

(define-public (system-detail-grid-page rc all-stats)
  (let* ((G_ (:i18n rc))
         ;; transformations to perform arithmetic on the raw stats
         (numeric-cpu-stat (lambda (s)
                             (string->number (format #f "~a"
                                                     (string-replace-substring
                                                      (assoc-ref s "stat_data")
                                                      "," ".")))))
         (numeric-mem-stat (lambda (s)
                             (string->number (format #f "~a"
                                                     (cadr (string-split (assoc-ref
                                                                          s
                                                                          "stat_data")
                                                                         #\space))))))
         ;; arithmetics
         (cpu-data (assoc-ref (assoc-ref all-stats
                                         'timeline-stats)
                              'cpu))
         (highest-cpu-stat #f)
         (latest-cpu-stat (list-ref cpu-data
                                    (- (length cpu-data) 1)))
         (_ (for-each (lambda (s)
                        (if highest-cpu-stat
                            (when (> (numeric-cpu-stat s)
                                     (numeric-cpu-stat highest-cpu-stat))
                              (set! highest-cpu-stat s))
                            (set! highest-cpu-stat s))) cpu-data))
         (mem-data (assoc-ref (assoc-ref all-stats
                                         'timeline-stats)
                              'mem))
         (highest-mem-stat #f)
         (latest-mem-stat (list-ref mem-data
                                    (- (length mem-data) 1)))
         (_ (for-each (lambda (s)
                        (if highest-mem-stat
                            (when (> (numeric-mem-stat s)
                                     (numeric-mem-stat highest-mem-stat))
                              (set! highest-mem-stat s))
                            (set! highest-mem-stat s))) mem-data))
         ;; display
         (cpu-html `(,(make-card #:title (G_ "current CPU load")
                                 #:stat-data (format #f "~,2h % on ~a"
                                                     (string->number (string-replace-substring
                                                                      (assoc-ref
                                                                       latest-cpu-stat
                                                                       "stat_data")
                                                                      "," "."))
                                                     (strftime "%c"
                                                               (localtime (assoc-ref
                                                                           latest-cpu-stat
                                                                           "updated_at"))))) ,
                     (make-card #:title (G_ "highest CPU load")
                                #:stat-data (format #f "~,2h % on ~a"
                                                    (string->number (string-replace-substring
                                                                     (assoc-ref
                                                                      highest-cpu-stat
                                                                      "stat_data")
                                                                     "," "."))
                                                    (strftime "%c"
                                                              (localtime (assoc-ref
                                                                          highest-cpu-stat
                                                                          "updated_at")))))))
         (mem-html `(,(make-card #:title (G_ "current memory usage")
                                 #:stat-data (format #f
                                              "~,2h GB of ~,2h GB on ~a"
                                              (exact->inexact (/ (string->number
                                                                  (cadr (string-split
                                                                         (assoc-ref
                                                                          latest-mem-stat
                                                                          "stat_data")
                                                                         #\space)))
                                                                 1024))
                                              (exact->inexact (/ (string->number
                                                                  (car (string-split
                                                                        (assoc-ref
                                                                         latest-mem-stat
                                                                         "stat_data")
                                                                        #\space)))
                                                                 1024))
                                              (strftime "%c"
                                                        (localtime (assoc-ref
                                                                    latest-mem-stat
                                                                    "updated_at"))))) ,
                     (make-card #:title (G_ "highest memory usage")
                                #:stat-data (format #f
                                             "~,2h GB of ~,2h GB on ~a"
                                             (exact->inexact (/ (string->number
                                                                 (cadr (string-split
                                                                        (assoc-ref
                                                                         highest-mem-stat
                                                                         "stat_data")
                                                                        #\space)))
                                                                1024))
                                             (exact->inexact (/ (string->number
                                                                 (car (string-split
                                                                       (assoc-ref
                                                                        highest-mem-stat
                                                                        "stat_data")
                                                                       #\space)))
                                                                1024))
                                             (strftime "%c"
                                                       (localtime (assoc-ref
                                                                   highest-mem-stat
                                                                   "updated_at")))))))
         ;; fixed stats
         (more-html (map (lambda (s)
                           (make-card #:title (assoc-ref s "id")
                                      #:stat-data (unescape-str (assoc-ref s
                                                                 "stat_data"))))
                         (assoc-ref all-stats
                                    'fixed-stats))))
    
    (oculuslambda-html-template G_
                                #:title (format #f "oculuslambda - ~a"
                                                (G_ "welcome to oculuslambda"))
                                #:body `((div (@ (class ,(->css '(mx-1 my-4
                                                                  flex
                                                                  flex-row
                                                                  flex-wrap
                                                                  justify-left
                                                                  gap-3))))
                                              ,cpu-html
                                              ,mem-html
                                              ,more-html)))))

