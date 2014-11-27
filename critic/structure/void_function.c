#include <critic.h>

struct critmod;

int init() {
	critmod.name = "void_function";
	critmod.criticality = 3;
	critmod.package = "structure";
	critmod.info = "Functions should return useful information, even if it's just an int 1 for success, 0 for failure.";
}

int violates (struct *node, struct *wholefile) {
	if (node.type != function) {
		return 0;
	}

	/* do check here XXX */
	if () {
		return 1;
	}

	return 0;
}
