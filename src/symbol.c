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
		free(funs);
	}	
}

void remove_vars(struct dvardef *vars) {
	if (vars != NULL) {
		remove_vars(vars->next);
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

}

int add_var(char *name, int type, struct frame *env) {

}

int main() {
	init();
	add_var("x", 1, cframe);
	add_var("y", 2, cframe);
}
