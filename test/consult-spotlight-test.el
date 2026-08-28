;;; consult-spotlight-test.el --- Tests for consult-spotlight -*- lexical-binding: t; -*-

(require 'cl-lib)
(require 'ert)
(require 'consult-spotlight)

(ert-deftest consult-spotlight--read-uses-process-collection ()
  "The command builder must be wrapped as an asynchronous collection."
  (let ((builder (lambda (_input) '("mdfind" "query")))
        process-builder
        process-properties
        read-collection
        read-properties)
    (cl-letf (((symbol-function 'consult--process-collection)
               (lambda (received-builder &rest properties)
                 (setq process-builder received-builder
                       process-properties properties)
                 'async-collection))
              ((symbol-function 'consult--file-preview)
               (lambda () 'preview-state))
              ((symbol-function 'consult--read)
               (lambda (collection &rest properties)
                 (setq read-collection collection
                       read-properties properties)
                 "/tmp/result")))
      (should (equal (consult-spotlight--read builder "Spotlight: " "query")
                     "/tmp/result"))
      (should (eq process-builder builder))
      (should (equal process-properties
                     `(:min-input ,consult-spotlight-min-input :highlight t)))
      (should (eq read-collection 'async-collection))
      (should (eq (plist-get read-properties :state) 'preview-state)))))

(provide 'consult-spotlight-test)
;;; consult-spotlight-test.el ends here
