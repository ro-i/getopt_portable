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

version_str = 0.1.0
name_str = getopt_portable

INCS = -I. -I/usr/include
CPPFLAGS = -DVERSION_STR=\"$(version_str)\"\
	   -DNAME_STR=\"$(name_str)\"

CFLAGS_DEBUG = -ggdb -std=c99 -pedantic -Wall -Wextra -Og $(INCS) $(CPPFLAGS)
CFLAGS_DEBUG_NO_OPT = -ggdb -std=c99 -pedantic -Wall -Wextra -O0 $(INCS) $(CPPFLAGS)
CFLAGS = -std=c99 -pedantic -Wall -Wextra -O2 -march=native $(INCS) $(CPPFLAGS)
CC = gcc

#prefix_dir = /usr/local
prefix_dir = ~/.local
