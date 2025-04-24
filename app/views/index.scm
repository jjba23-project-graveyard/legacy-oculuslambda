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
  #:use-module (artanis artanis)
  #:use-module (artanis i18n sxml)
  #:use-module (hygguile abstraction)
  #:use-module (artanis i18n locale)
  #:use-module (ice-9 textual-ports)
  #:use-module (ice-9 string-fun))

(define-public (dashboard-page rc state)
  (let* ((G_ (:i18n rc))
         (welcome-html `((h1 (@(class ,(->css '(text-2xl font-bold)))) ,(G_ "oculuslambda"))
                         (h3 (em ,(G_ "the eye into the system's functioning")))
                         (dl (@(class ,(->css '(mx-1 my-4))))
                             ,(map (lambda(s)
                                     `((dt (@(class ,(->css '(font-bold)))) ,(symbol->string (car s)))
                                       (dd (@(class ,(->css '( overflow-auto text-sm p-1 mx-2 whitespace-pre font-mono)))) ,(cdr s)))) state)))))
    (oculuslambda-html-template G_
                                #:title (format #f "oculuslambda - ~a"
                                                (G_ "welcome to oculuslambda"))
                                #:body welcome-html)))

