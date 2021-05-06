getopt_portable
===============

Simple and portable command line frontend for libgetopt_portable.
Initially, it has been created to test libgetopt_portable, but it may be
useful otherwise, too.

Project Status
--------------
I wrote this software some time ago in order to learn something new and
in order to use it and to play with it. However, I am no longer satisfied
with the current state of the project. That's why it is now archived for the
time being. :)

Test
----
You may test particular optstrings like this:
`./test.sh --valgrind /opt/scripts/bin/getopt_portable b:rd -bzzz -rd`
which should give the output:
`"-b" "zzz" "-r" "-d"`

Or you may run the default test set:
`make test`
