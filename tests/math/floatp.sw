inherit /std/test;

string command, expected_result;

create() {
	mixed value;

	command = "floatp(5);";
	expected_result = "0";
	do_test(command, expected_result);

	command = "floatp(5.1);";
	expected_result = "1";
	do_test(command, expected_result);

	command = "floatp(\"woohoo\");";
	expected_result = "0";
	do_test(command, expected_result);

	command = "floatp(value);";
	expected_result = "0";
	do_test(command, expected_result);

	value = 5.5;
	command = "floatp(value);";
	expected_result = "1";
	do_test(command, expected_result);
}
