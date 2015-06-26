#define TYPE_VOID 10
#define TYPE_INT  11
#define TYPE_FLOAT  12
#define TYPE_STRING 13
#define TYPE_OBJECT 14
#define TYPE_MAPPING 15
#define TYPE_MIXED 16

struct fargs {
	int type;
	char *name;
	struct fargs *next;
};

struct dfuncdef {
	int type;
	char *name;
	int numargs;
	int *argtypes;  
	struct dfuncdef *next;
	struct frame *env;
};

struct dvardef {
	int type;
	char *name;
	struct dvardef *next;
};

struct frame {
	struct frame *prev;
	struct dvardef *vars;
	struct dfuncdef *funs;
};

