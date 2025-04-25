(import (artanis mvc model))

(create-artanis-model time_stat
                      (:deps)
                      (id char-field
                          (#:not-null #:maxlen 512))
                      (stat_data char-field
                                 (#:not-null #:maxlen 16384))
                      (updated_at date-field
                                  (#:not-null)))
