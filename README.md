# Quickproject

[![Build Status](http://img.shields.io/travis/nlamirault/quickproject.svg)](https://travis-ci.org/nlamirault/quickproject)


## Description

This is a fork of [Quickproject](https://github.com/xach/quickproject).
Quickproject creates the skeleton of a Common Lisp project.
For full documentation, see [here](http://xach.com/lisp/quickproject).


## Intallation

Add the projet and load it using [Quicklisp](http://www.quicklisp.org):

    CL-USER> (push #p"/projects/quickproject/" asdf:*central-registry*)
    CL-USER> (ql:quickload "quickproject")


## Usage

* Creates a new project :

        CL-USER> (quickproject:make-project #p"/tmp/myproject/"
                                            :depends-on '(drakma hunchentoot)
                                            :ci t)
        "myproject"
        CL-USER> (directory #p"/tmp/myproject/*.*")
        (#P"/tmp/myproject/README.md"
		 #P"/tmp/myproject/ci/"
         #P"/tmp/myproject/myproject-test.asd"
		 #P"/tmp/myproject/myproject.asd"
         #P"/tmp/myproject/src/"
		 #P"/tmp/myproject/test/")

* A test project is created for unit tests :

        CL-USER> (ql:quickload "my-project-test")

* For continuous integration, a script is available :

        $ bash /tmp/myproject/ci/myproject-ci.sh


## Hacking

* Fork, hack and run unit tests:

        CL-USER> (ql:quickload "quickproject-test")
		CL-USER> (lisp-unit:run-tests :all :quickproject-test)


## License

Quickproject is licensed under the MIT license; see LICENSE.txt for
details.

## Changelog

A changelog is available [here](ChangeLog.md).


## Contact

Nicolas Lamirault <nicolas.lamirault@gmail.com>
