/* 	Code needed from page 67

type infer (Env T, Exp p) 		Infer type of expression
void check (Env T, Exp p, type t) 	check type of expression
void check (Env T, Stms s)		check type of statements
void check (Env T, def f)		check the definition of a function
void check (program p)			check a whole program
type lookup (Env T, ident x)		Lookup a variable
funtype lookup (Env T, ident x)		lookup a function
env	extend (Env T, ident x, type t) Define a variable
env	extend (Env T, def d)		Define a function
env	newblock (Env T)		enter a new block
env	emptyenv ()			empty environment

*/

#include <stdlib.h>
#include <string.h>
#include "symbol.h"

static struct frame topframe;
struct frame *cframe;

void init() {
	cframe = &topframe;
	cframe->funs = NULL;
	cframe->vars = NULL;
	cframe->prev = NULL;
}

struct frame *addframe() {
	struct frame *tmp;

	tmp = malloc(sizeof(struct frame));
	tmp->funs = NULL;
	tmp->vars = NULL;
	tmp->prev = cframe;
	cframe = tmp;

	return cframe;
}

void remove_funs(struct dfuncdef *funs) {
	if (funs != NULL) {
		remove_funs(funs->next);
		free(funs->name);
		free(funs);
	}	
}

void remove_vars(struct dvardef *vars) {
	if (vars != NULL) {
		remove_vars(vars->next);
		free(vars->name);
		free(vars);
	}	
}

struct frame *remove_frame() {
	struct frame *tmp;

	tmp = cframe;
	cframe = tmp->prev;
	if (tmp != NULL) {
		remove_funs(tmp->funs);
		remove_vars(tmp->vars);
		free(tmp);
	}
	return cframe;
}

/* XXX Need to do args */
int add_fun(char *name, int type, struct frame *env) {
	struct dfuncdef *tmp;
	int size;

	tmp = malloc(sizeof(struct dfuncdef));
	tmp->type = type;
	size = strlen(name) + 1;
	tmp->name = malloc(sizeof(char) * size);
	strncpy(tmp->name, name, size);
	tmp->next =env->funs;
	env->funs = tmp;

	return 1;
}

int add_var(char *name, int type, struct frame *env) {
	struct dvardef *tmp;
	int size;

	tmp = malloc(sizeof(struct dvardef));
	tmp->type = type;
	size = strlen(name) + 1;
	tmp->name = malloc(sizeof(char) * size);
	strncpy(tmp->name, name, size);
	tmp->next =env->vars;
	env->vars = tmp;

	return 1;
}

struct dfuncdef *find_func(char *name, struct dfuncdef *list) {

	while (list) {
		if (strcmp(list->name, name) == 0) {
			return list;
		}
	}

	return NULL;
}

struct dvardef *find_var(char *name, struct dvardef *list) {

	while (list) {
		if (strcmp(list->name, name) == 0) {
			return list;
		}
	}

	return NULL;
}

struct dfuncdef *get_func(char *name, struct frame *env) {
	struct dfuncdef *tmp;

	if (!env) {
		return 0;
	}
	tmp = find_func(name, env->funs);

	if (!tmp) {
		return get_func(name, env->prev);
	}

	return tmp;
}

struct dvardef *get_var(char *name, struct frame *env) {
	struct dvardef *tmp;

	if (!env) {
		return 0;
	}
	tmp = find_var(name, env->vars);

	if (!tmp) {
		return get_var(name, env->prev);
	}

	return tmp;
}

int get_variable_type(char *name, struct frame *env) {
	struct dvardef *tmp;

	tmp = get_var(name, env);
	if (tmp) {
		return tmp->type;
	}

	return 0;
}

int get_function_type(char *name, struct frame *env) {
	struct dfuncdef *tmp;

	tmp = get_func(name, env);
	if (tmp) {
		return tmp->type;
	}

	return 0;
}

int main() {
	int x;

	init();
	add_var("x", TYPE_INT, cframe);
	add_var("y", TYPE_FLOAT, cframe);

	x = get_variable_type("x",cframe);
}
