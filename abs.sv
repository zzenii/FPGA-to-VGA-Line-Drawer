/*
	abs is a combinational module that receives WIDTH-bit inputs and returns the 'distance'
	between the inputs, as a WIDTH-bit output. This module is heavily used by input_selector
	to manage the algorithm reduction process outlined in Lab3.pdf.
*/



module abs #(
	// The algorithm requires different input widths: 10 for x values, 9 for y values.
	parameter WIDTH = 10
	)(
	input logic [WIDTH-1:0] val_1, val_2,
	output logic [WIDTH-1:0] out
	);
	
	// Combinational logic to assert the output.
	always_comb begin
		if (val_1 > val_2)
			out = val_1 - val_2;
		else
			out = val_2 - val_1;
	end
endmodule


// This testbench seeks to check that each of the 3 possible cases are properly handled:
// val_1 >, <, = val_2. The result should be the appropriate *unsigned* logic value.

module abs_testbench();
	
	parameter WIDTH = 10;
	logic [WIDTH-1:0] val_1, val_2, out;
	
	abs #(WIDTH) dut (.val_1, .val_2, .out);
	
	initial begin
		val_1 <= 10'b0001100111; val_2 <= 10'b0101100111; #50; // val_1 < val_2. 
		val_1 <= 10'b0101100111; val_2 <= 10'b0001100111; #50; // val_1 > val_2. Should produce same result as prior line.
		val_1 <= 10'b0101100111; val_2 <= 10'b0101100111; #50; // val_1 = val_2. Should give 0.
		#50;
	end //initial
endmodule
		
