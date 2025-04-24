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

(define-module (oculuslambda metrics)
  #:use-module (ice-9 time)
  #:use-module (ice-9 format)
  #:use-module (ice-9 rdelim)
  #:use-module (ice-9 textual-ports)
  #:use-module (ice-9 regex)
  #:use-module (app models stat)
  #:use-module (srfi srfi-1)
  #:use-module (srfi srfi-64)
  #:use-module (oculuslambda prelude)
  #:use-module (oculuslambda process)
  #:use-module (oculuslambda query-escape)
  #:use-module (ice-9 string-fun)
  #:use-module (ice-9 iconv))

(define-public (get-uptime)
  (syscall-silent "uptime"))

(define-public (get-uname)
  (syscall-silent "uname -a"))

(define-public (get-hostname)
  (syscall-silent "hostname"))

(define-public (get-mem)
  (syscall-silent "free -h"))

(define-public (get-disk)
  (syscall-silent "df -h"))

(define-public (get-part)
  (syscall-silent "lsblk"))

(define-public (record-stat stat cmd)
  ($stat 'set
         #:id stat
         #:stat_data (syscall-silent cmd)
         #:stat_cmd  cmd
         #:updated_at (current-time)
         #:condition (where #:id (symbol->string stat))))
