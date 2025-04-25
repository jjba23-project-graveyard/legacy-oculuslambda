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
  #:use-module (app models time_stat)
  #:use-module (srfi srfi-1)
  #:use-module (artanis db)
  #:use-module (artanis ssql)
  #:use-module (fibers)
  #:use-module (srfi srfi-64)
  #:use-module (oculuslambda prelude)
  #:use-module (oculuslambda process)
  #:use-module (oculuslambda query-escape)
  #:use-module (ice-9 string-fun)
  #:use-module (ice-9 iconv))

(define-public (record-stat stat cmd)
  (let* ((stat-data (syscall cmd))
         (now (current-time)))
    (catch #t
      (lambda ()
        ($stat 'set
               #:id stat
               #:stat_data (escape-str stat-data)
               #:updated_at now))
      (lambda (key . args)
        (catch #t
          (lambda ()
            (let* ((conn (get-conn-from-pool!)))
              (DB-query conn
                        (->sql update
                               'stat set
                               `((id ,stat)
                                 (stat_data ,(escape-str stat-data))
                                 (updated_at ,now))
                               (where #:id stat)))
              (DB-close conn)))
          (lambda (key . args)
            (display (format #f "error saving metric: ~a: ~a: ~a ~a" stat
                             cmd key args))))))))

(define-public (record-time-stat stat cmd)
  (let* ((stat-data (syscall cmd))
         (retention-period (* 48 60 60))
         (now (current-time)))
    (catch #t
      (lambda ()
        (let* ((conn (get-conn-from-pool!)))
          (DB-query conn
                    (format #f "DELETE FROM time_stat WHERE updated_at < ~a" (- now retention-period)))
          (DB-close conn)))  
      (lambda (key . args)
        (display (format #f "error cleaning metric: ~a: ~a ~a" stat key args))))
    (catch #t
      (lambda ()
        ($time_stat 'set
                    #:id stat
                    #:stat_data (escape-str stat-data)
                    #:updated_at now))
      (lambda (key . args)
        (display (format #f "error saving metric: ~a: ~a: ~a ~a" stat
                         cmd key args))))))

(define-public (oculuslambda-worker-thread)
  (display (format #f
                   "\n~a...\n"
                   (gettext
                    "initializing oculuslambda queue worker")))

  (use-modules (oculuslambda metrics)
               (fibers)
               (app models stat)
               (app models time_stat))
  
  (run-fibers
   (lambda()
     (spawn-fiber (lambda()
                    (while #t
                      (sleep (* 1 60))
                      (record-stat 'hostname "hostname")
                      (record-stat 'uptime "uptime")
                      (record-stat 'uname "uname -a")
                      (record-stat 'disk "df -h")
                      (record-stat 'part "lsblk")
                      (record-stat 'podman "podman ps -a")
                      )))
     (spawn-fiber (lambda()
                    (while #t
                      (sleep (* 0.2 60))
                      (record-time-stat 'cpu "uptime | awk '{print substr($9, 1, length($9)-1)}'")
                      ;; mem is total,used,free,available format
                      (record-time-stat 'mem
                                        "free -g | tail -n 2 | head -n 1 | awk '{print $2,$3,$4,$7}'")))))
   #:drain? #t))
