inherit /std/test;

string command, expected_result;

test_switch(mixed x) {

	switch(x) {
		case "x" {
			return 1;
		} case 1 {
			return 2;
		} else {
			return 3;
		}
	}
}

create() {
	command = "test_switch(\"x\");";
	expected_result = "1";
	do_test(command, expected_result);

	command = "test_while(1)";
	expected_result = "2";
	do_test(command, expected_result);

	command = "test_while(3)";
	expected_result = "3";
	do_test(command, expected_result);
}
