/* 
	A unit test should:
	Set up all conditions for testing.
	Call the method (or Trigger) being tested.
	Verify that the results are correct.
	Clean up modified records. (Not really necessary on Force.com.)
*/

struct testval {
	int total;
	int errors;
};

struct testval testres;

int test_get_conf_name () {
	char *name, *name2;
	int x = 0;

	testres.total += 2;

	name = get_conf_name("lpc");
	if (strcmp(name, ".lpcrc") != 0) {
		printf("test_get_conf_name: test1 expected \"%s\" got \"%s\"\n",
			".lpcrc", name);
		x++;
	}
	name2 = get_conf_name("sweet");
	if (strcmp(name, ".sweetrc") != 0) {
		printf("test_get_conf_name: test2 expected \"%s\" got \"%s\"\n",
			".sweetrc", name);
		x++;
	}

	testres.total += 2;
	testres.errors += x;

	return x;
}

int main() {
	if (!test_get_conf_name()) {
		printf("test_get_conf_name: OK\n");
	}

	printf("Total tests: %s\n", testres.total);
	printf("Total errors: %s\n", testres.errors);
}
