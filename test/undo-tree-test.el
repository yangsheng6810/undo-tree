;;; undo-tree-test.el --- Tests for undo-tree
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
      (undo-tree-undo)
      (should (string-equal "1234567890" (buffer-string)))
      (undo-tree-redo)
      (should (string-equal "1234abcd567890" (buffer-string)))
      ))

(ert-deftest undo-tree-test/undo-tree-size ()
  "Simple undo works for insertion and deletion"
  (with-temp-buffer
    (buffer-enable-undo)
    (undo-tree-mode 1)
    (insert "1234567890")
    (undo-boundary)
    (goto-char 5)
    (insert "abcd")
    (undo-boundary)
    (undo-list-transfer-to-tree)
    (should (equal (undo-tree-calc-tree-size (undo-tree-root buffer-undo-tree))
                   (undo-tree-size buffer-undo-tree)))
    (undo-tree-undo)
    (should (equal (undo-tree-calc-tree-size (undo-tree-root buffer-undo-tree))
                   (undo-tree-size buffer-undo-tree)))
    (undo-tree-redo)
    (should (equal (undo-tree-calc-tree-size (undo-tree-root buffer-undo-tree))
                   (undo-tree-size buffer-undo-tree)))
    ))
;;; undo-tree-test.el ends here
