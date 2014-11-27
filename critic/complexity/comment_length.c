#include <critic.h>

struct critmod;

int init() {
	critmod.name = "comment_length";
	critmod.criticality = 3;
	critmod.package = "complexity";
	critmod.info = "Comment blocks that span more than 10 lines.  Consider refactoring this code fo a function so you can comment it out with one line.  If this comment is describing what a function or variable does, it should use the builtin commenting features of our language.\nExample:\nXXX";
}

int getline_count(struct *node) {
/* XXX */
}

int violates (struct *node, struct *wholefile) {
	if (node.type != comment) {
		return 0;
	}

	if (getline_count(node) > 10) {
		return 1;
	}

	return 0;
}
