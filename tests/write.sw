inherit /std/test;

string command, expected_result;

create() {
	string a;
	int b;

	command = "write(\"Hello\")";
	expected_result = "Hello";

	do_test(command,expected_result);

	a = "Frank";
	command = "write(\"Hello \" + a + \"\n\")";
	expected_result = "Hello Frank\n";

	do_test(command,expected_result);

	b = 1;
	command = "write(\"Hello \" + b + \"\n\")";
	expected_result = "Hello 1\n";

	do_test(command,expected_result);
}
