;;; undo-tree-test.el --- Tests for undo-tree
(require 'cl-lib)
(require 'dash)
(load-file "undo-tree.el")
(ert-deftest undo-tree-test/undo ()
  "Simple undo works for insertion and deletion"
  (with-temp-buffer
    (buffer-enable-undo)
    (undo-tree-mode 1)
    (insert "1234567890")
    (undo-boundary)
    (goto-char 5)
    (insert "abcd")
    (undo-boundary)
    (should (string-equal "1234abcd567890" (buffer-string)))
    (undo-tree-undo 1)
    (should (string-equal "1234567890" (buffer-string)))
    (undo-tree-redo 1)
    (should (string-equal "1234abcd567890" (buffer-string)))
    ))

(ert-deftest undo-tree-test/undo-tree-size ()
  "Simple undo-tree size tests"
  (with-temp-buffer
    (buffer-enable-undo)
    (undo-tree-mode 1)
    (insert "1234567890")
    (undo-boundary)
    (goto-char 5)
    (insert "abcd")
    (undo-boundary)
    (undo-tree-transfer-list-to-tree)
    (undo-tree-verify-size)
    (undo-tree-undo 1)
    (undo-tree-verify-size)
    (undo-tree-redo 1)
    (undo-tree-verify-size)
    ))

(ert-deftest undo-tree-test/undo-tree-size-1 ()
  "More undo-tree size tests"
  (with-temp-buffer
    (buffer-enable-undo)
    (undo-tree-mode 1)
    (undo-tree-test-setup)
    (dotimes (_ 20)
      (goto-char (point-min))
      (replace-string "lorem" "dignissim-")
      (undo-boundary)
      (goto-char (point-min))
      (replace-string "dignissim-" "lorem--")
      (undo-boundary)
      (goto-char (point-min))
      (replace-string "lorem--" "dignissim---")
      (undo-boundary)
      (goto-char (point-min))
      (replace-string "dignissim---" "lorem")
      (undo-boundary))
    (undo-tree-transfer-list-to-tree)
    ;; (should (string-equal "(nil undo-tree-canary)" (format "%s" buffer-undo-list)))
    ;; (should (string-equal "t" "nil"))

    (undo-tree-verify-size)
    ;; (should (string-equal "t" "nil"))
    ;; (undo-tree-print-undo-tree)
    (undo-tree-undo 60)
    (undo-tree-verify-size)
    (undo-tree-redo 40)
    (undo-tree-verify-size)))

(ert-deftest undo-tree-test/undo-tree-simple-tree ()
  "Simple undo-tree size tests"
  (with-temp-buffer
    (buffer-enable-undo)
    (undo-tree-mode 1)
    (insert "1234567890")
    (undo-boundary)
    (should (string-equal (buffer-string) "1234567890"))

    (goto-char 5)
    (insert "abcd")
    (undo-boundary)
    (should (string-equal (buffer-string) "1234abcd567890"))

    (goto-char 10)
    (insert "qwerty")
    (undo-boundary)
    (should (string-equal (buffer-string) "1234abcd5qwerty67890"))

    (undo-tree-undo 1)
    (should (string-equal (buffer-string) "1234abcd567890"))

    (goto-char 0)
    (insert "0987")
    (undo-boundary)
    (should (string-equal (buffer-string) "09871234abcd567890"))

    (undo-tree-undo 1)
    (should (string-equal (buffer-string) "1234abcd567890"))

    (undo-tree-switch-branch 1)
    (undo-tree-redo 1)
    (should (string-equal (buffer-string) "1234abcd5qwerty67890"))
    (should (equal (undo-tree-calc-tree-size buffer-undo-tree)
                   (undo-tree-size buffer-undo-tree)))
    ))

(ert-deftest undo-tree-test/undo-tree-rebuild-undo-list ()
  "Test if the undo-list built from undo-tree works"
  (with-temp-buffer
    (buffer-enable-undo)
    (undo-tree-mode 1)
    (insert "1234567890")
    (undo-boundary)
    (should (string-equal (buffer-string) "1234567890"))

    (goto-char 5)
    (insert "abcd")
    (undo-boundary)
    (should (string-equal (buffer-string) "1234abcd567890"))

    (goto-char 10)
    (insert "qwerty")
    (undo-boundary)
    ;; this is end of branch 1
    (should (string-equal (buffer-string) "1234abcd5qwerty67890"))

    (undo-tree-undo 1)
    ;; this is the diverging point
    (should (string-equal (buffer-string) "1234abcd567890"))

    (goto-char 0)
    (insert "0987")
    (undo-boundary)
    ;; this is end of branch 2
    (should (string-equal (buffer-string) "09871234abcd567890"))

    (undo-tree-undo 1)
    ;; this is the diverging point
    (should (string-equal (buffer-string) "1234abcd567890"))

    (undo-tree-switch-branch 1)
    (undo-tree-redo 1)
    (undo-boundary)
    ;; this is end of branch 1
    (should (string-equal (buffer-string) "1234abcd5qwerty67890"))

    (undo-tree-mode -1)
    (message "Turning off undo-tree mode")

    (undo-tree-verify-undo
     '(
       ;; this is end of branch 1
       (0 "1234abcd5qwerty67890")
       ;; this is the diverging point
       (1 "1234abcd567890")
       ;; this is end of branch 2
       (2 "09871234abcd567890")
       ;; this is the diverging point
       (3 "1234abcd567890")
       (4 "1234567890")
       (5 "")))))

(ert-deftest undo-tree-test/save-load ()
  "Test if the loaded undo-tree is the same as the saved one, by
storing the undo-tree just loaded"
  (let* ((undo-tree-file "1.undo-tree")
         (text-file "1.el")
         (tree (undo-tree-load-history--helper undo-tree-file))
         (file1 (make-temp-file "undo-tree--test"))
         (file2 (make-temp-file "undo-tree--test"))
         str1 str2)
    ;; The test is done as follows: we first load a saved undo-tree, and save it
    ;; in FILE1. Then we load the tree in FILE1, and save it in FILE2. The final
    ;; test is done by comparing the undo-tree in UNDO-TREE-FILE and FILE2. The
    ;; second round is a simple trick to deal with strings with text property.
    ;; For example, the following is a string "t" with fontified as t and face
    ;; as font-lock-string-face.
    ;;
    ;;   #("t" 0 1 (fontified t face font-lock-string-face))
    ;;
    ;; After printing it with PRIN1, it will be
    ;;
    ;;   #("t" 0 1 (face font-lock-string-face fontified t))
    ;;
    ;; This is equivalent, since the format is `(key1 value1 key2 value2 ...)'.
    ;; But this causes trouble for equal test. As a simple workaround, we add a
    ;; second round. It is possible to implement a customize function for more
    ;; intelligent equality check, but let's delay it.

    (find-file text-file)
    (undo-tree--save-tree-stable tree (current-buffer) file1)
    (setq tree (undo-tree-load-history--helper file1))
    (undo-tree--save-tree-stable tree (current-buffer) file2)
    (find-file undo-tree-file)
    (setq str1 (buffer-string))
    (find-file file2)
    (setq str2 (buffer-string))
    (should (string-equal str1 str2))
    ;; (ignore-errors
    ;;   (delete-file filename))
    ))

;; TODO: add test for GCed undo-tree
;;; undo-tree-test.el ends here
