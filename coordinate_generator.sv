/*
	coordinate_generator brings together the datapath and controller modules to achieve the 
	desired results: calculating intermediate coordinates between two points to form a line.
	We note that each of the 9 possible input cases are handled by input_selector, thus we can correctly
	assume that the line described by the modified values of (x0, y0), (x1, y1) is not steep, and
	we can traverse from left to right.
	
	This module accepts 10-bit inputs x0, x1, y0, y1, that describe the points we must connect.
	It additionally accepts 1-bit input is_steep, which informs the module that a swap is necessary at the output.
	Finally, it accepts 1-bit set, which causes these inputs to be stored in the internal registers (enable).
	The module outputs 10/9-bit coordinates x and y to VGA_framebuffer.
*/


module coordinate_generator (
			input logic clk, reset, set, is_steep,
			
			// These signals come from input_selector, which handles the swapping process.
			// Thus, each value is a 10-bit input to avoid truncating an x value.
			input logic [9:0] x0, x1, y0, y1,
			
			output logic [9:0] x,
			output logic [8:0] y
			);
	
	// Intermediate status and control signals (see control-datapath Block Diagram in Lab3.pdf.
	logic loop_condition, steep, err_gtz;
	logic idle_default, set_regs, incr_loop, swap, no_swap, new_line, no_new_line;
	
	// Instance of the controller module (inputs and outputs are described above and in Lab3.pdf.)
	coordinate_generator_controller control (.clk, .reset, .set, .loop_condition, .steep, .err_gtz,
														.idle_default, .set_regs, .incr_loop, .swap, .no_swap, .new_line, .no_new_line);
	
	// Instance of the datapath module (inputs and outputs are described above and in Lab3.pdf.)
	coordinate_generator_datapath datapath (.clk, .reset, .x0, .x1, .y0, .y1, .x, .y, .is_steep,
														.loop_condition, .steep, .err_gtz,
														.idle_default, .set_regs, .incr_loop, .swap, .no_swap, .new_line, .no_new_line);
endmodule


`timescale 1ns / 1ps

/* 
	This testbench evaluates the coordinate generator's validity in each of the possible input cases.
	However, given the state reduction process carried out by input_selector, our inputs must satisfy the following properties:
	1. We are always traversing from smaller to larger values of x.
	2. The line represented by the modified values of x0, x1, y0, y1 are never steep, 
	as input_selector swaps the x and y coordinates for a steep line. However, the input is_steep is asserted in this case.
	Thus, this leaves us six different cases:
	Horizontal, vertical, and each binary combination of (is_steep)(step is positive).
*/

module coordinate_generator_testbench();

	logic clk, reset, set, is_steep;
	logic [9:0] x0, x1, y0, y1;
	logic [9:0] x;
	logic [8:0] y;
	
	coordinate_generator dut (.clk, .reset, .set, .is_steep, .x0, .x1, .y0, .y1, .x, .y);
	
	// Establishing clock behaviour.
	parameter clock_period = 20;
	initial begin
		clk <= 0;
		forever #(clock_period/2) clk <= ~clk;
	end
	
	initial begin
		reset <= 1;	set <= 0;								@(posedge clk)
		reset <= 0;										@(posedge clk)
		x0 <= 10'd1; y0 <= 10'd1; x1 <= 10'd6; y1 <= 10'd1; is_steep <= 0; set <= 1; 		@(posedge clk) // Horizontal Line
		set <= 0;										@(posedge clk)
		repeat (20) @(posedge clk); // We must give our state machine enough time to calculate 6 coordinates (3 cycles each), and return to s_idle.
		x0 <= 10'd1; y0 <= 10'd1; x1 <= 10'd6; y1 <= 10'd1; is_steep <= 1; set <= 1; 		@(posedge clk) // Vertical Line
		set <= 0;										@(posedge clk)
		repeat (20) @(posedge clk);																					
		x0 <= 10'd1; y0 <= 10'd1; x1 <= 10'd6; y1 <= 10'd3; is_steep <= 0; set <= 1; 		@(posedge clk) // Line, not steep, positive step
		set <= 0;										@(posedge clk)
		repeat (20) @(posedge clk);
		x0 <= 10'd1; y0 <= 10'd1; x1 <= 10'd6; y1 <= 10'd3; is_steep <= 1; set <= 1; 		@(posedge clk) // Line, steep, positive step
		set <= 0;										@(posedge clk)
		repeat (20) @(posedge clk);
		x0 <= 10'd1; y0 <= 10'd3; x1 <= 10'd6; y1 <= 10'd1; is_steep <= 0; set <= 1; 		@(posedge clk) // Line, not steep, negative step
		set <= 0;										@(posedge clk)
		repeat (20) @(posedge clk);
		x0 <= 10'd1; y0 <= 10'd3; x1 <= 10'd6; y1 <= 10'd1; is_steep <= 1; set <= 1; 		@(posedge clk) // Line, steep, negative step
		set <= 0;										@(posedge clk)
		repeat (20) @(posedge clk);
		$stop;
	end
endmodule
	
	






