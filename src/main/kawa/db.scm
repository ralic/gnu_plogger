(define-library (plogger db)
  (import (class java.sql DriverManager)
          (kawa base)
          (plogger config)
          )
  (export db-connect)
  (begin
    ;;(define *db* (db-connect))
    (define (db-connect)
      (let* ((url (format "jdbc:sqlite:~a/plogger.db" (config-path))))
        (java.lang.Class:forName "org.sqlite.JDBC")
        (DriverManager:getConnection url)))))
