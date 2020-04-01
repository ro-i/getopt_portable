getopt_portable
===============

Simple and portable command line frontend for libgetopt_portable.
Initially, it has been created to test libgetopt_portable, but it may be
useful otherwise, too.

Project Status
--------------
This software is under development, a work-in-progress. It is not yet stable
or suitable for general use.

Test
----
You may test particular optstrings like this:
`./test.sh --valgrind /opt/scripts/bin/getopt_portable b:rd -bzzz -rd`
which should give the output:
`"-b" "zzz" "-r" "-d"`

Or you may run the default test set:
`make test`
