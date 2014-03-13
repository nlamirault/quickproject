;;; Unit tests for QuickProject

(in-package #:quickproject-test)



(defun search-token-into-file (token filename)
  (let ((scanner (cl-ppcre:create-scanner token))
	(find-token nil))
    (with-open-file (stream filename)
      (loop for line = (read-line stream nil nil)
	 while line
	 when (cl-ppcre:scan scanner line)
	 do (setf find-token t)))
    find-token))

(defun get-random-name ()
  (format nil "qp-tests-~A~A" (get-universal-time) (random 1000)))

(defun make-project-file (path filename)
  (merge-pathnames path filename))

(defun make-source-file (path filename)
  (merge-pathnames
   (cl-fad:pathname-as-directory (merge-pathnames path "src"))
   filename))

(defun make-test-file (path filename)
  (merge-pathnames
   (cl-fad:pathname-as-directory (merge-pathnames path "test"))
   filename))

(defun make-ci-file (path filename)
  (merge-pathnames
   (cl-fad:pathname-as-directory (merge-pathnames path "ci"))
   filename))

(define-test cant-create-project-directory-with-invalid-path
  (let ((path #p"/dev/random/foo/"))
    (assert-error 'file-error (make-project path))
    (assert-false (cl-fad:directory-exists-p path))))

;; (define-test cant-create-project-with-directory-existing
;;   (let ((path (pathname (format nil "/tmp/~A-foo/" (get-random-name)))))
;;     (ensure-directories-exist path)
;;     (assert-error 'file-error (make-project path))))

(defmacro with-project ((name path &key ci depends-on) &body body)
  `(let* ((,name (get-random-name))
	  (,path (pathname (format nil "/tmp/~A/" ,name))))
     (make-project ,path :depends-on ,depends-on :ci ,ci)
     ,@body))

(define-test can-create-project
  (with-project (name path)
    (mapc (lambda (directory)
	    (assert-true (cl-fad:directory-exists-p directory)))
	  (list path
		(merge-pathnames path "src")
		(merge-pathnames path "test")))
    (assert-equal 5 (list-length (cl-fad:list-directory path)))
    (mapc #'(lambda (filename)
	      (assert-true (cl-fad:file-exists-p
			    (make-project-file path filename))))
	  (list (format nil "~A.asd" name)
		(format nil "~A-test.asd" name)
		"README.md"))
    (mapc (lambda (filename)
	    (assert-true (cl-fad:file-exists-p filename)))
	  (list (make-source-file path "package.lisp")
		(make-source-file path (format nil "~A.lisp" name))
		(make-test-file path "package.lisp")
		(make-test-file path (format nil "~A-test.lisp" name))))))

(define-test can-create-project-with-ci
  (with-project (name path :ci t)
    (assert-true (cl-fad:directory-exists-p path))
    (assert-true (cl-fad:directory-exists-p
		  (merge-pathnames path "ci")))
    (mapc (lambda (file)
	    (assert-true (cl-fad:file-exists-p
			  (make-ci-file path file))))
	  (list "init.lisp"
		(format nil "~A-ci.lisp" name)
		(format nil "~A-ci.sh" name)))))

(define-test check-default-description-header
  (with-project (name path)
    (assert-true (search-token-into-file
  		  (format nil ":description \"Describe ~A here\"" name)
  		  (make-project-file path (format nil "~A.asd" name))))))

(define-test check-default-author-header
  (with-project (name path)
    (assert-true (search-token-into-file
		  (format nil ":author \"Your Name <your.name@example.com>\"")
		  (make-project-file path (format nil "~A.asd" name))))))

(define-test check-default-license-header
  (with-project (name path)
    (assert-true (search-token-into-file
		  (format nil ":license \"Specify license here\"")
		  (make-project-file path (format nil "~A.asd" name))))))

(define-test check-customize-author-header
  (let* ((author "Foo Bar <foo.bar@gmail.com>")
	 (quickproject:*author* author))
    (with-project (name path)
      (assert-true (search-token-into-file
		    (format nil ":author \"~A\"" author)
		    (make-project-file path (format nil "~A.asd" name)))))))

(define-test check-customize-license-header
  (let* ((license "DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE")
	 (quickproject:*license* license))
    (with-project (name path)
      (assert-true (search-token-into-file
		    (format nil ":license \"~A\"" license)
		    (make-project-file path (format nil "~A.asd" name)))))))

(define-test check-project-dependencies
  (let ((dependencies '(drakma hunchentoot)))
    (with-project (name path :depends-on dependencies)
      (let ((project-file (make-project-file path (format nil "~A.asd" name))))
	(mapc (lambda (dep)
		(assert-true (search-token-into-file (format nil "#:~A"
							     (string-downcase dep))
						     project-file)))
	      dependencies)))))

(define-test check-project-test-dependencies
  (let ((dependencies '(drakma hunchentoot)))
    (with-project (name path :depends-on dependencies)
      (let ((project-file (make-project-file path (format nil "~A-test.asd" name))))
	(mapc (lambda (dep)
		(assert-false (search-token-into-file (format nil "#:~A"
							     (string-downcase dep))
						     project-file)))
	      dependencies)
	(assert-true (search-token-into-file (format nil "#:~A" name)
					     project-file))))))

(define-test check-project-module
  (with-project (name path)
    (let ((project-file (make-project-file path (format nil "~A.asd" name))))
      (assert-true
       (search-token-into-file ":module :src" project-file)))))

(define-test check-project-test-module
  (with-project (name path)
    (let ((project-file (make-project-file path (format nil "~A-test.asd" name))))
      (assert-true
       (search-token-into-file ":module :ttest" project-file)))))
