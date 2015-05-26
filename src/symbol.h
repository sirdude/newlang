struct dfuncdef {
    char class;                 /* function class */
    char inherit;               /* function name inherit index */
    unsigned short index;       /* function name index */
    unsigned int offset;                /* offset in program text */
    struct dfuncdef *next;
};

struct dvardef {
    char class;                 /* variable class */
    char type;                  /* variable type */
    char inherit;               /* variable name inherit index */
    unsigned short index;       /* variable name index */
    struct dvardef *next;
};

struct frame {
	struct frame *prev;
	struct dvardef *vars;
	struct dfuncdef *funs;
};

