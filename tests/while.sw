inherit /std/test;

string command, expected_result;

test_while(int x) {
	string str;

	str = "";
	while (x < 10) {
		str += x + ", ";
	}
	str += "\n";

	return str;
}

create() {
	# Normal test
	command = "test_while(0);";
	expected_result = "1, 2, 3, 4, 5, 6, 7, 8, 9, 10, \n";
	do_test(command, expected_result);

	# Boarder case
	command = "test_while(10)";
	expected_result = "\n";
	do_test(command, expected_result);

	# Outside case
	command = "test_while(11)";
	expected_result = "\n";
	do_test(command, expected_result);
}
