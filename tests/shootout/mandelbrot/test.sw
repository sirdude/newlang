#!/usr/bin/sweet

int main() {
	string command, res;

	command = "./mandelbrot.sw";
	res = "";
	do_test(command, res);

	command = "./mandelbrot.sw 5";
	res = "";
	do_test(command, res);
}
