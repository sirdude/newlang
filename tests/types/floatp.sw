inherit /std/test;

string command, expected_result;

create() {
	int x, *arrx;
	string y, *arry;
	float a, *arra;
	mixed b, *arrb;

	# Test simple if
	command = "floatp(nil)";
	expected_result = "0";
	do_test(command,expected_result);

	
	command = "floatp(x)";
	expected_result = "0";
	do_test(command,expected_result);


	command = "floatp(y)";
	expected_result = "0";
	do_test(command,expected_result);

	command = "floatp(a)";
	expected_result = "1";
	do_test(command,expected_result);


	command = "floatp(b)";
	expected_result = "0";
	do_test(command,expected_result);

	command = "floatp(arrx)";
	expected_result = "0";
	do_test(command,expected_result);

	command = "floatp(arry)";
	expected_result = "0";
	do_test(command,expected_result);

	command = "floatp(arra)";
	expected_result = "0";
	do_test(command,expected_result);

	command = "floatp(arrb)";
	expected_result = "0";
	do_test(command,expected_result);
}
