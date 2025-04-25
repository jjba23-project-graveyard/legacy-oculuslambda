(import (artanis mvc model))

(create-artanis-model stat
                      (:deps)
                      (id char-field
                          (#:primary-key #:maxlen 512))
                      (stat_data char-field
                                 (#:not-null #:maxlen 16384))
                      (updated_at date-field
                                  (#:not-null)))
