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
                                   "This is a system monitoring tool, observability, alerting, dashboarding and more, all configurable in Lisp (Guile Scheme).")))
                         )))
    (oculuslambda-html-template G_
                                #:title (format #f "oculuslambda - ~a"
                                                (G_ "welcome to oculuslambda"))
                                #:body welcome-html)))

(define-public (system-detail-list-page rc state)
  (let* ((G_ (:i18n rc))
         (welcome-html `((dl (@ (class ,(->css '(mx-1 my-4 flex flex-col gap-3))))
                             ,(map (lambda (s)
                                     `((div (@(class ,(->css '(p-2 bg-stone-300 rounded-xl))))
                                            (dt (@ (class ,(->css '(font-bold))))
                                                ,(assoc-ref s "id"))
                                            (dd (@ (class ,(->css '(overflow-auto
                                                                    text-sm p-1
                                                                    mx-2
                                                                    whitespace-pre
                                                                    font-mono))))
                                                ,(unescape-str (assoc-ref s
                                                                          "stat_data"))))))
                                   state)))))
    (oculuslambda-html-template G_
                                #:title (format #f "oculuslambda - ~a"
                                                (G_ "welcome to oculuslambda"))
                                #:body welcome-html)))

(define-public (system-detail-grid-page rc state)
  (let* ((G_ (:i18n rc))
         (welcome-html `((div (@ (class ,(->css '(mx-1 my-4 grid grid-cols-1 sm:grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-2))))
                              ,(map (lambda (s)
                                      `((div (@(class ,(->css '(p-2 bg-stone-300 rounded-xl))))
                                             (span (@(class ,(->css '(font-bold)))) ,(assoc-ref s "id"))
                                             (div (@ (class ,(->css '(overflow-auto
                                                                      text-sm p-1
                                                                      mx-2
                                                                      whitespace-pre
                                                                      font-mono))))
                                                  ,(unescape-str (assoc-ref s
                                                                            "stat_data"))))
                                        
                                        ))
                                    state)))))
    (oculuslambda-html-template G_
                                #:title (format #f "oculuslambda - ~a"
                                                (G_ "welcome to oculuslambda"))
                                #:body welcome-html)))

