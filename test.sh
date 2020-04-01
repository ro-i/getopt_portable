#!/bin/sh

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

usage () {
	printf '%s\n' "usage: $0 /path/to/getopt_portable [OPTSTRING [ARGS]...]"
	printf '%s\n' "   or: $0 OPTION /path/to/getopt_portable OPTSTRING [ARGS]..."
	printf 'Run test set on getopt_portable.
  options available:
    --gdb       debug with gdb
    -h, --help  show this help
    --valgrind  debug with valgrind\n'
}

## test functions ##

debug_gdb () {
	gdb --args "$getopt_portable_bin" "$optstring" "$@"
}

debug_valgrind () {
	valgrind -q --leak-check=full --show-leak-kinds=all \
		--errors-for-leak-kinds=all "$getopt_portable_bin" "$optstring" "$@"
	printf '\n'
}

default () {
	if [ -z "$optstring" ]; then
		default_static "$@"
	else
		# operate on user provided data
		default_variable "$@"
	fi
}

default_static () {
	default_static_intern ":ab:c" '"-a" "-b" "arg"' -a -barg
	default_static_intern "abcdefg" '"-c" "-a" "-g"' -cag
	default_static_intern "a:bc" '"-a" "zzz" "-b" "-c"' -azzz -bc
	default_static_intern "abc:" '"-a" "-b" "-c" "zzz"' -abczzz

	error_invalid_option "abc" -ag
	error_invalid_option "a:bc" -ng

	error_missing_argument "a:bc" -a
	error_missing_argument "a:bc:" -aarg -c
	error_missing_argument "a:bc:" -a arg -c

	no_error ":abc" -g
	no_error ":a:bc" -a
}

default_static_intern () {
	optstring="$1"
	shift
	result="$1"
	shift

	OPTIONS=$(getopt_portable "$optstring" "$@" 2>&1)
	if [ "$OPTIONS" != "$result" ]; then
		printf 'default_static: test "%s" failed; should be: %s, but was: %s\n' \
			"$optstring" "$result" "$OPTIONS"
	else
		printf 'default_static: test "%s" succeeded.\n' "$optstring"
	fi
}

default_variable () {
	OPTIONS=$(getopt_portable "$optstring" "$@")

	# set parsed options as new positional arguments
	set -- "$OPTIONS"

	printf 'exit_code: %d\n' $?
	printf 'result: %s\n' "$@"
}

error_invalid_option () {
	optstring="$1"
	shift

	first_invalid_option=$(printf '%s' "$*" | tr -d "\\- $optstring" | head -c1)

	if ! getopt_portable "$optstring" "$@" 2>&1 \
		| grep -q "invalid option -- '$first_invalid_option'"
	then
		printf 'error_invalid_option: test "%s" failed.\n' "$optstring"
	else
		printf 'error_invalid_option: test "%s" succeeded.\n' "$optstring"
	fi
}

error_missing_argument () {
	optstring="$1"
	shift

	argument_options=$(printf '%s' "$optstring" | grep -o '[[:alnum:]]:' | tr -d ':\n')
	last_argument_option_given=$(printf '%s' "$*" | tr -cd "$argument_options" | tail -c1)

	if ! getopt_portable "$optstring" "$@" 2>&1 \
		| grep -q "option requires an argument -- '$last_argument_option_given'"
	then
		printf 'error_missing_argument: test "%s" failed.\n' "$optstring"
	else
		printf 'error_missing_argument: test "%s" succeeded.\n' "$optstring"
	fi
}

# if optstring starts with a colon, getopt must not print any error message
no_error () {
	optstring="$1"
	shift

	OPTIONS=$(getopt_portable "$optstring" "$@" 2>&1)
	if [ -n "$OPTIONS" ]; then
		printf 'no_error: test "%s" failed.\nThere should be no ouput, but was: %s\n' \
			"$optstring" "$OPTIONS"
	else
		printf 'no_error: test "%s" succeeded.\n' "$optstring"
	fi
}


case "$1" in
	"--gdb")
		shift
		test_cmd () { debug_gdb "$@"; }
		;;
	"-h"|"--help")
		usage
		exit 0
		;;
	"--valgrind")
		shift
		test_cmd () { debug_valgrind "$@"; }
		;;
	*)
		default_test=1
		test_cmd () { default "$@"; }
		;;
esac

getopt_portable_bin="$1"
if [ ! -x "$getopt_portable_bin" ]; then
	printf '%s\n' "$getopt_portable_bin: file not found or not executable"
	exit 1
fi
shift

optstring="$1"
if [ -z "$optstring" ] && [ -z "$default_test" ]; then
	usage; exit 1
elif [ -n "$optstring" ]; then
	shift
fi

test_cmd "$@"
