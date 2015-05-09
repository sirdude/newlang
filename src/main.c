#include <unistd.h>
#include <limits.h>
#include <stdio.h>
#include <stdlib.h>
#include <getopt.h>
#include <string.h>
#include <libgen.h>
#include <libconfig.h>

#include "Parser.h"
#include "Printer.h"
#include "Absyn.h"

#define MAX_STR 2048
#define DEFAULT_CRITIC_LEVEL 3

extern char *get_version();

char *lib_path, *inc_path, *conf_path, *critic_path, *conf_file;
int critic_level;

int print = -1;
int help = -1;
int critic = -1;
int libdir = -1;
int incdir = -1;
int output = -1;
int version = -1;
int test = -1;
int upgrade = -1;
int opt = 0;

static struct option long_options[] = {
	{"print",	no_argument,		0,	'p' },
	{"help",	no_argument,		0,	'h' },
	{"critic",	optional_argument,	0,	'c' },
	{"config",	required_argument,	NULL,	'C' },
	{"include",	required_argument,	NULL,	'I' },
	{"level",	required_argument,	NULL,	'l' },
	{"lib",		required_argument,	NULL,	'L' },
	{"output",	required_argument,	NULL,	'o' },
	{"upgrade",	no_argument,		NULL,	'u' },
	{"version",	no_argument,		NULL,	'v' },
	{"test",	no_argument,		NULL,	't' },
	{0,		0,			0,	0 }
};

int print_version(char *name, char *dir) {
	printf("%s Version: %s\n\n", name, get_version());
	printf("Working dir: %s\n", dir);
	if (strcmp(name,"lpc") == 0) {
		printf("LPC_CONF_PATH: %s\n", conf_path);
		printf("LPC_CONF_FILE: %s\n", conf_file);
		printf("LPC_CRITIC_PATH: %s\n", critic_path);
		printf("LPC_INC_PATH: %s\n", inc_path);
		printf("LPC_LIB_PATH: %s\n\n", lib_path);

		printf("LPC_CRITIC_LEVEL: %d\n\n", critic_level);
	} else {
		printf("SWEET_CONF_PATH: %s\n", conf_path);
		printf("SWEET_CONF_FILE: %s\n", conf_file);
		printf("SWEET_CRITIC_PATH: %s\n", critic_path);
		printf("SWEET_INC_PATH: %s\n", inc_path);
		printf("SWEET_LIB_PATH: %s\n\n", lib_path);

		printf("SWEET_CRITIC_LEVEL: %d\n\n", critic_level);
	}

	printf("Found inheritables:\n");
/* XXX */
	return 1;
}

char *get_conf_name(char *name) {
	if (strcmp(name, "lpc") == 0) {
		return ".lpcrc";
	}
	return ".sweetrc";
}

int print_usage(char *name) {
	printf("Usage: %s [OPTIONS] [INFILE]\n", name);
	printf("\tEvaluate the file INFILE.  If no file is given, read ");
	printf("from stdin.\n");
	printf("Available Options:\n");
	printf("\t-c --critic[=PATH]\n\t\tPrint feedback on the submitted ");
	printf("code.  if PATH is specified,\n\t\tadd PATH to the search ");
	printf("path for critic config files.\n");
	printf("\t-C --config=PATH\n\t\tSpecify a path to search for ");
	printf("config files.\n");
	printf("\t-h --help\n\t\tThis usage information.\n");
	printf("\t-I --include=PATH\n\t\tSpecify a path to search for ");
	printf("include files.\n");
	printf("\t-L --lib=PATH\n\t\tSpecify a path to search for ");
	printf("inheritables.\n");
	printf("\t-L --level=NUM\n\t\tSet the critic level 0-5, 5 being harsh "
		);
	printf("inheritables.\n");
	printf("\t-o --output=FILE\n\t\tSpecify a filename to compile ");
	printf("the code to.\n");
	printf("\t-p --print\n\t\tParse the file and then print it in the ");
	printf("standard format.\n");
	printf("\t-t --test\n\t\tRun all of the test_* functions ");
	printf("in the code.\n");
	printf("\t-u --upgrade\n\t");
	printf("\tUpgrade the specified file to the current syntax.\n");
	printf("\t-v --version\n\t");
	printf("\tPrint Version and configuration information.\n\n");

	printf("You can also use the following environment variables ");
	printf("to modify configuration:\n");
	if (strcmp(name,"lpc") == 0) {
		printf("\tLPC_CONF_PATH\n");
		printf("\tLPC_CRITIC_PATH\n");
		printf("\tLPC_INC_PATH\n");
		printf("\tLPC_LIB_PATH\n");
		printf("\tLPC_CRITIC_LEVEL\n\n");
	} else {
		printf("\tSWEET_CONF_PATH\n");
		printf("\tSWEET_CRITIC_PATH\n");
		printf("\tSWEET_INC_PATH\n");
		printf("\tSWEET_LIB_PATH\n");
		printf("\tSWEET_CRITIC_LEVEL\n\n");
	}

	printf("Alternately you can create a config file: %s\n", 
		get_conf_name(name));

	if (strcmp(name,"lpc") == 0) {
		printf("and place it in LPC_CONF_PATH.\n");
	} else {
		printf("and place it in SWEET_CONF_PATH.\n");
	}

	return 0;
}

char *add_configs(char *localpath, char *value) {
	char *tmp;
	int size;

	if (value) {
		if (localpath) {
			tmp = localpath;
			size = strlen(value) + strlen(tmp) + 2;
			localpath = malloc(size * sizeof(char));
			strncat(localpath, tmp, size);
			strncat(localpath, ":", size);
		} else {
			size = strlen(value) + 1;
			localpath = malloc(size * sizeof(char));
		}
		strncat(localpath, value, size);
	}

	return localpath;
}

int read_env_configs(char *name) {
	if (strcmp(name,"lpc") == 0) {
		conf_path = add_configs(conf_path, getenv("LPC_CONF_PATH"));
		critic_path = add_configs(critic_path,
			getenv("LPC_CRITIC_PATH"));
		inc_path = add_configs(inc_path, getenv("LPC_INC_PATH"));
		lib_path = add_configs(lib_path, getenv("LPC_LIB_PATH"));

		if (getenv("LPC_CRITIC_LEVEL")) {
			critic_level = atoi(getenv("LPC_CRITIC_LEVEL"));
		}
	} else {
		conf_path = add_configs(conf_path, getenv("SWEET_CONF_PATH"));
		critic_path = add_configs(critic_path,
			getenv("SWEET_CRITIC_PATH"));
		inc_path = add_configs(inc_path, getenv("SWEET_INC_PATH"));
		lib_path = add_configs(lib_path, getenv("SWEET_LIB_PATH"));

		if (getenv("SWEET_CRITIC_LEVEL")) {
			critic_level = atoi(getenv("SWEET_CRITIC_LEVEL"));
		}
	}
	return 1;
}

int read_conf_file(char *path) {
	FILE *file;

	printf("Checking conf: %s\n", path);

	if ((file = fopen(path, "r"))) {
		conf_file = path;
		fclose(file);
		return 1;
	}

	return 0;
}

int load_conf_file(char *name) {
	char *buf, tmp[MAX_STR];
	int size;

	while (buf = strtok(conf_path, ":")) {
		size = strlen(buf);
printf("Buf = %s size = %d\n", buf, size);
		strncpy(tmp, buf, size);
		tmp[size + 1] = '\0';
printf("tmp = %s size = %d\n", tmp, strlen(tmp));
		strncat(tmp, get_conf_name(name), MAX_STR);
printf("tmp = %s size = %d\n", tmp, strlen(tmp));
		if (read_conf_file(tmp)) {
			return 1;
		}

	}
	buf = strtok(conf_path, NULL);
	size = strlen(buf);
	strncpy(tmp, buf, size);
	tmp[size + 1] = '\0';
	strncat(tmp, get_conf_name(name), MAX_STR);
	if (read_conf_file(tmp)) {
		return 1;
	}

	return 0;
}

int read_file_configs(char *name, char *dir) {
	char *tmp, *tmp2;
	int size;

	tmp = malloc(MAX_STR * sizeof(char));
	tmp2 = malloc(MAX_STR * sizeof(char));

	size = strlen(dir);
	strncpy(tmp, dir, size);
	tmp[size + 1] = '\0';
	strncat(tmp, "/etc", MAX_STR);
	conf_path = add_configs(conf_path, tmp);

	load_conf_file(name);

	strncpy(tmp, dir, size);
	tmp[size + 1] = '\0';
	strncat(tmp, "include/", MAX_STR);
	strncat(tmp, name, MAX_STR);
	inc_path = add_configs(inc_path, tmp);

	strncpy(tmp, dir, size);
	tmp[size + 1] = '\0';
	strncat(tmp, "lib/", MAX_STR);
	strncat(tmp, name, MAX_STR);

	strncpy(tmp2, tmp, strlen(tmp));
	tmp2[strlen(tmp) + 1] = '\0';
	strncat(tmp2, "/critic", MAX_STR);
	critic_path = add_configs(critic_path, tmp2);

	strncpy(tmp2, tmp, strlen(tmp));
	tmp2[strlen(tmp) + 1] = '\0';
	lib_path = add_configs(lib_path, tmp2);

	free(tmp);
	free(tmp2);
	return 0;
}

int do_critic(char *outfile, Program parse_tree) {
	printf("Inside do_critic: XXX Needs to be implemented.\n");
	return 0;
}

int run_tests(char *outfile, Program parse_tree) {
	printf("Inside run_tests: XXX Needs to be implemented.\n");
	return 0;
}

int print_file(char *outfile, Program parse_tree) {
	FILE *ofile;

	if (output == 1) {
		ofile = fopen(outfile,"w");
		if (!ofile) {
			fprintf(stderr,"Unable to write to file: %s\n",
				outfile);
			return 0;
		}

		fprintf(ofile,"%s\n", printProgram(parse_tree));

		fclose(ofile);
	} else {
		printf("[Linearized Tree]\n");
		printf("%s\n\n", printProgram(parse_tree));
	}
	return 1;
}

int run_code(char *outfile, Program parse_tree) {
	printf("Inside run_code: XXX Needs to be implemented.\n");
	return 0;
}

int main(int argc, char ** argv) {
	FILE *input;
	char buf[MAX_STR];
	char *outfile, *basepath, *filename, *fullpath;
	Program parse_tree;
	int outfilelen, ret, long_index = 0;

	critic_level = DEFAULT_CRITIC_LEVEL;

	fullpath = realpath(argv[0],buf);
	basepath = dirname(fullpath);
	filename = basename(fullpath);

	outfile = NULL;

	while ((opt = getopt_long(argc, argv, "hptuvc::C:L:I:l:o:",
		long_options, &long_index)) != -1) {
		switch (opt) {
			case 'c':
				if (optarg) {
					outfilelen = strlen(optarg) + 1;
					critic_path = malloc(outfilelen * 
						sizeof(char));
					strncpy(critic_path,optarg,outfilelen);
				}
				critic = 1;
				break;
			case 'C':
				outfilelen = strlen(optarg) + 1;
				conf_path = malloc(outfilelen * sizeof(char));
				strncpy(conf_path,optarg,outfilelen);
				break;
			case 'L':
				outfilelen = strlen(optarg) + 1;
				lib_path = malloc(outfilelen * sizeof(char));
				strncpy(lib_path,optarg,outfilelen);
				break;
			case 'l':
				critic_level = atoi(optarg);
				break;
			case 'I':
				outfilelen = strlen(optarg) + 1;
				inc_path = malloc(outfilelen * sizeof(char));
				strncpy(inc_path,optarg,outfilelen);
				break;
			case 'o':
				output = 1;
				outfilelen = strlen(optarg) + 1;
				outfile = malloc(outfilelen * sizeof(char));
				strncpy(outfile,optarg,outfilelen);
				break;
			case 'p':
				print = 1;
				break;
			case 'u':
				upgrade =1;
				break;
			case 'v':
				version =1;
				break;
			case 't':
				test = 1;
				break;
			default:
				print_usage(filename);

				if (outfile) {
					free(outfile);
				}

				return 0;
		}
	}

	read_env_configs(filename);
//	read_file_configs(filename, basepath);

	if (optind < argc) {
		input = fopen(argv[optind], "r");

		if (!input) {
			fprintf(stderr, "Error opening input file: %s\n",
				argv[optind]);
			exit(1);
		}
	} else {
		input = stdin;
	}

	if (version == 1) {
		return print_version(filename, basepath);
	}

	if (upgrade == 1) {
		/* Need to upgrade our code XXX which is more complicated 
			version of parse_tree */
		parse_tree = pProgram(input);
		
	} else {
		parse_tree = pProgram(input);
	}

	if (parse_tree) {
		if (print == 1) {
			ret= print_file(outfile, parse_tree);
		} else if (critic == 1) {
			ret = do_critic(outfile, parse_tree);
		} else if (test == 1) {
			ret = run_tests(outfile, parse_tree);
		} else {
			ret = run_code(outfile, parse_tree);
		}
		if (outfile) {
			free(outfile);
		}

		return ret;
	}

	return 1;
}

