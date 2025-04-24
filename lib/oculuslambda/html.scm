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

(define-module (oculuslambda html)
  #:use-module (oculuslambda query-escape)
  #:use-module (sxml simple)
  #:use-module (ice-9 popen)
  #:use-module (ice-9 textual-ports)
  #:use-module (ice-9 time)
  #:use-module (ice-9 format)
  #:use-module (oculuslambda prelude)
  #:use-module (web uri)
  #:use-module (hygguile abstraction)
  #:use-module (hygguile components icon)
  #:use-module (hygguile components button)
  #:use-module (artanis artanis)
  #:use-module (ice-9 string-fun)
  #:use-module (ice-9 iconv)
  #:use-module (ice-9 threads))

(begin
  (define* (oculuslambda-html-template G_
                                       #:key title body
                                       (should-auto-refresh #f))
    (let ((maybe-auto-refresh (cond
                               ((equal? should-auto-refresh #t)
                                `(meta (@ (content "10")
                                          (http-equiv "refresh")) ()))
                               (else `()))))
      
      `("<!DOCTYPE html>" (html (@ (lang en))
                                (head (title ,title)
                                      (style ,(assoc-ref asset-library
                                                         "pub/css/fonts.css"))
                                      (style ,(assoc-ref asset-library
                                                         "pub/css/phosphor.css"))

                                      ,maybe-auto-refresh
                                      (meta (@ (name viewport)
                                               (content
                                                "width=device-width, initial-scale=1.0")))
                                      (script ,(assoc-ref asset-library
                                                          "pub/js/tailwind.js"))
                                      (script ,(assoc-ref asset-library
                                                          "pub/js/tailwind.config.js")))
                                (body (@ (class ,(->css '(bg-stone-200))))
                                      (div (@ (class ,(->css '(flex flex-col
                                                                    h-screen
                                                                    justify-between))))
                                           (div ,(page-top G_)
                                                (div (@ (class ,(->css '(my-4
                                                                         container
                                                                         mx-auto))))
                                                     ,@body))
                                           ,(page-footer G_)))))))
  (export oculuslambda-html-template))

(define-public (page-top G_)
  `((div (@(class ,(->css '(my-6 mx-2))))
         (div (@(class ,(->css '(flex flex-row flex-wrap justify-left align-center gap-3))))
              (h1 (@ (class ,(->css '(text-3xl font-bold))))
                  (a (@(href "/")) ,(G_ "oculuslambda")))
              (div (@ (class ,(->css '(flex flex-row flex-wrap
                                            gap-4
                                            justify-center
                                            align-center w-max))))
                   (a (@ (href "/dashboard/system-detail-list"))
                      ,(hyg-button #:content (G_
                                              "system detail list")))
                   (a (@ (href "/dashboard/system-detail-grid"))
                      ,(hyg-button #:content (G_
                                              "system detail grid")))))
         (h3 (em ,(G_ "the eye into the system's functioning"))))))

(define-public (page-footer G_)
  `((div (p ,(G_ "licensed under the GPL v3 or later"))
         (p ,(G_ "Copyright &copy; Josep Bigorra &lt;jjbigorra@gmail.com&gt;")))))

