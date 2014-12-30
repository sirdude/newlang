inherit /std/test;

string command, expected_result;

string test_if (int x) {
	if (x) {
		return 1;
	}
	return 0;
}

string test_if_else (int x) {
	if (x) {
		return 1;
	} else {
		return 0;
	}
	return -1; # Should never get this...
}

string test_elseif (int x) {
	if (x) {
		return 1;
	} elseif (y) {
		return 0;
	}
	return -1;
}

string test_full_if (int x, int y) {
	if (x) {
		return 1;
	} elseif (y) {
		return 0;
	} else {
		return -1;
	}
}

create() {
	int x, y;

	# Test simple if
	command = "test_if(1)";
	expected_result = "1";
	do_test(command,expected_result);

	command = "test_if(0)";
	expected_result = "0";
	do_test(command,expected_result);


	# Test if with else
	command = "test_if_else(1)";
	expected_result = "1";
	do_test(command,expected_result);

	command = "test_if_else(0)";
	expected_result = "0";
	do_test(command,expected_result);


	# Test if with elseif
	command = "test_elseif(1,0)";
	expected_result = "1";
	do_test(command,expected_result);

	command = "test_elseif(0,1)";
	expected_result = "0";
	do_test(command,expected_result);

	command = "test_elseif(0,0)";
	expected_result = "-1";
	do_test(command,expected_result);


	# Test all options if, elseif, else
	command = "test_full_if(1,0)";
	expected_result = "1";
	do_test(command,expected_result);

	command = "test_full_if(0,1)";
	expected_result = "0";
	do_test(command,expected_result);

	command = "test_full_if(0,0)";
	expected_result = "-1";
	do_test(command,expected_result);
}
