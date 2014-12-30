inherit /std/test;

string command, expected_result;

create() {
	int x;

	x = 0;
	command = "while (x < 10) { " +
		"   write(x + \",\"); " +
		"} write(\"\n\")";

	expected_result = "1, 2, 3, 4, 5, 6, 7, 8, 9, 10\n";
	do_test(command, expected_result);

	expected_result = "";
	do_test(command, expected_result);
}
