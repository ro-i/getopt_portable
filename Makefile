# getopt_portable - command line frontend for libgetopt_portable
# Copyright (C) 2019-2020 Robert Imschweiler
#
# This file is part of getopt_portable.
#
# getopt_portable is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# getopt_portable is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with getopt_portable.  If not, see <https://www.gnu.org/licenses/>.
.POSIX:

include config.mk

bin = $(name_str)
hdr = $(name_str).h libgetopt_portable/libgetopt_portable.h
src = $(name_str).c libgetopt_portable/libgetopt_portable.c
obj = ${src:.c=.o}
files = COPYING libgetopt_portable/COPYING README.md test.sh \
	libgetopt_portable/README.md Makefile config.mk $(hdr) $(src)

all: $(bin)

debug: CFLAGS = $(CFLAGS_DEBUG)
debug: $(bin)
debug_no_opt: CFLAGS = $(CFLAGS_DEBUG_NO_OPT)
debug_no_opt: $(bin)

$(bin): $(obj)
	$(CC) $(CFLAGS) -o $(bin) $^

%.o: %.c $(hdr)
	$(CC) $(CFLAGS) -c -o $@ $<

clean:
	rm -f $(bin) $(obj) test

dist:
	tar -czvf $(bin)_$(version_str).orig.tar.gz $(files)

install:
	install $(bin) $(DESTDIR)$(prefix_dir)/bin

test:
	cp test.sh test
	chmod a+x test
	@echo Running test...
	/bin/sh ./test $(DESTDIR)$(prefix_dir)/bin/$(bin)

.PHONY: all clean debug dist install test
