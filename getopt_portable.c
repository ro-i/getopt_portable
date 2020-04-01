/*
 * getopt_portable - command line frontend for libgetopt_portable
 * Copyright (C) 2019-2020 Robert Imschweiler
 * 
 * This file is part of getopt_portable.
 * 
 * getopt_portable is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * 
 * getopt_portable is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with getopt_portable.  If not, see <https://www.gnu.org/licenses/>.
 */

#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "libgetopt_portable/libgetopt_portable.h"


static int
count_args(char * const args[])
{
	int count = 0;

	while (args[count++]);

	return count-1;
}

static char **
get_argv_extern(char * const args[], int argc_extern)
{
	char **argv_extern;
	int i;

	if (!(argv_extern = malloc(sizeof(char *)*(argc_extern+1)))) {
		perror("malloc");
		exit(3);
	}
	if (!(argv_extern[0] = getenv("_"))) {
		fprintf(stderr, "%s: could not determine value of '_' "
				"environment variable\n", NAME_STR);
		free(argv_extern);
		exit(3);
	}
	for (i = 1; args[i-1]; i++)
		argv_extern[i] = args[i-1];
	argv_extern[i] = NULL;

	return argv_extern;
}

static void
output(char **new_argv, int new_argc)
{
	for (int i = 0; i < new_argc; i++) {
		if (i)
			putchar(' ');
		printf("\"%s\"", new_argv[i]);
	}
}

static int
getopt_portable_command_line(int argc_extern, char * const argv_extern[],
		const char *optstring)
{
	char **new_argv = NULL;
	int new_argc = 0, opt, result = 0;


	while ((opt = getopt_portable(argc_extern, argv_extern, optstring)) != -1) {
		if (opt == ':' || opt == '?') {
			result = 1;
			break;
		}
		new_argv = realloc(new_argv, sizeof(char *)*(new_argc+1));
		if (!new_argv) {
			perror("realloc");
			return 3;
		}
		if (!(new_argv[new_argc] = malloc(3))) {
			perror("malloc");
			result = 3;
			break;
		}
		sprintf(new_argv[new_argc], "-%c", opt);

		new_argc++;
		if (!opt_arg)
			continue;

		new_argv = realloc(new_argv, sizeof(char *)*(new_argc+1));
		if (!new_argv) {
			perror("realloc");
			return 3;
		}
		if (!(new_argv[new_argc] = malloc(strlen(opt_arg)+1))) {
			perror("malloc");
			result = 3;
			break;
		}
		strcpy(new_argv[new_argc], opt_arg);
		new_argc++;
	}

	if (!result)
		output(new_argv, new_argc);

	if (new_argv) {
		while (new_argc--)
			free(new_argv[new_argc]);
		free(new_argv);
	}

	return result;
}

int
main(int argc, char **argv)
{
	char **argv_extern;
	int argc_extern, result;

	if (argc < 2) {
		fprintf(stderr, "usage: %s OPTSTRING [ARGS]...\n", NAME_STR);
		return 2;
	} else if (argc < 3) {
		/* no options to parse */
		return 0;
	}

	argc_extern = count_args(&argv[2])+1;
	argv_extern = get_argv_extern(&argv[2], argc_extern);

	result = getopt_portable_command_line(argc_extern, argv_extern, argv[1]);

	free(argv_extern);

	return result;
}
