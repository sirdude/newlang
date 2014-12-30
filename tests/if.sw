inherit /std/test;

string command, expected_result;

create() {
	int x, y;

	command = "if (x) { return 1; } " +
		"elseif (y) { return 0; } " +
		"else { return -1;}";

	x = 1; y = 0;
	expected_result = "return 1";
	do_test(command,expected_result);

	x = 0; y = 1;
	expected_result = "return 0";
	do_test(command,expected_result);

	x = 0; y = 0;
	expected_result = "return -1";

	do_test(command,expected_result);
}
