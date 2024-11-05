/*
	input_sanitizer is an FSM that regulates an input signal by interpreting a constant logic 1 as a single signal pulse.
	It accepts 1-bit input in, and asserts the single pulse signal out. The FSM is synchronized to clk with asynch. reset.
*/

module input_sanitizer (clk, reset, in, out);
	input logic clk, reset, in;
	output logic out;
	
	// There are two states: OFF and ON
	enum {OFF, ON} ps, ns;
	
	// Next state logic (see state diagram in Lab2.pdf)
	always_comb begin
		case (ps)
			OFF:	if (in) ns = ON;
				else ns = OFF;
			ON: 	if (in) ns = ON;
				else ns = OFF;
		endcase
	end
	
	// asserting output.
	assign out = ~ps & in;
	
	// State transitions.
	always_ff @(posedge clk) begin
		if (reset)
			ps <= OFF;
		else 
			ps <= ns;
	end
endmodule 


// Testbench verifies that a continued assertion of in is interpreted as a single pulse. All state transitions are validated herein. 

module input_sanitizer_testbench();
	logic clk, reset, in, out;
	
	input_sanitizer dut (.clk, .reset, .in, .out);
	
	parameter CLOCK_PERIOD = 20;
	initial begin
		clk <= 0;
		forever #(CLOCK_PERIOD/2) clk <= ~clk;
	end
	
	initial begin
		reset <= 1;	in <= 0;	@(posedge clk)
		reset <= 0;			@(posedge clk)	
		
		repeat(10) begin
			@(posedge clk) in <= 1; 
		end
		repeat(10) begin
			@(posedge clk) in <= 0; 
		end
		$stop;
	end
endmodule

						
