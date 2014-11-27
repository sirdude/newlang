#include <critic.h>

struct critmod;

int init() {
	critmod.name = "var_comment";
	critmod.criticality = 3;
	critmod.package = "structure";
	critmod.info = "Variables should have a comment: Examples:\n\tGood: int x "Our counter";\n\tBad: int x;";
}

int has_comment(struct *node) {
/* XXX */
}

int violates (struct *node, struct *wholefile) {
	if (node.type != var) {
		return 0;
	}

	/* do check here XXX */
	if (!has_comment(node)) {
		return 1;
	}

	return 0;
}
