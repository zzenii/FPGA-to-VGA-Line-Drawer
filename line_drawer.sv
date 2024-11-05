/*
	line_drawer brings together the input_selector and coordinate_generator modules to generate the
	correct coordinates between any two points on a 640x480 VGA display. It does this in two steps:
	First, input_selector handles the algorithm reduction process by ensuring that the outputted points
	satisfy the following:
	
	1. We are always traversing from smaller to larger values of x.
	2. The line represented by the modified values of x0, x1, y0, y1 are never steep, 
	
	Then, coordinate_generator implements the remaining calculations seen in the pseudo-code.
	
	This module accepts 10-bit inputs x0, x1, and 9-bit inputs y0, y1, that describe the points we must connect.
	Also, it accepts 1-bit set, which causes these inputs to be stored in the internal registers (enable).
	The module outputs 10/9-bit coordinates x and y to VGA_framebuffer.
*/

module line_drawer(
	input logic clk, reset, set,
	
	// x and y coordinates for the start and end points of the line
	input logic [9:0]	x0, x1, 
	input logic [8:0] y0, y1,

	//outputs cooresponding to the coordinate pair (x, y)
	output logic [9:0] x,
	output logic [8:0] y 
	
	);
	
	logic [9:0] temp_x0, temp_x1, temp_y0, temp_y1;
	
	// If an x-y swap was necessary in input_selector, temp signal is_steep is asserted.
	logic is_steep;
   
	// Instance of input_selector: algorithm reduction. I/O described above.
	input_selector select (.x0, .y0, .x1, .y1, .start_h(temp_x0), .end_h(temp_x1), .start_v(temp_y0), .end_v(temp_y1), .is_steep);

	// Instance of coordinate_generator: calculation. I/O described above.
	coordinate_generator calculate (.x0(temp_x0), .x1(temp_x1), .y0(temp_y0), .y1(temp_y1), .is_steep, .set, .reset, .clk, .x, .y);
	
endmodule



`timescale 1ns / 1ps

/* 
	This testbench seeks to validate the behaviour of the line_drawer for each of the 9 input cases.
*/
module line_drawer_testbench();

	logic clk, reset, set;
	logic [9:0] x0, x1, x;
	logic [8:0] y0, y1, y;
	
	line_drawer dut (.clk, .reset, .set, .x0, .x1, .y0, .y1, .x, .y);
	
	// Establishing clock behaviour.
	parameter clock_period = 20;
	initial begin
		clk <= 0;
		forever #(clock_period/2) clk <= ~clk;
	end
	
	initial begin
		reset <= 1;	set <= 0;						@(posedge clk)
		reset <= 0;								@(posedge clk)
		x0 <= 10'd1; y0 <= 9'd1; x1 <= 10'd6; y1 <= 9'd1; set <= 1; 		@(posedge clk) // Horizontal Line, left to right
		set <= 0;								@(posedge clk)
		repeat (20) @(posedge clk);
		
		x0 <= 10'd6; y0 <= 9'd1; x1 <= 10'd1; y1 <= 9'd1; set <= 1; 		@(posedge clk) // Horizontal Line, right to left
		set <= 0;								@(posedge clk)
		repeat (20) @(posedge clk);
		
		x0 <= 10'd1; y0 <= 9'd1; x1 <= 10'd1; y1 <= 9'd6; set <= 1; 		@(posedge clk) // Vertical Line, small to large in y
		set <= 0;								@(posedge clk)
		repeat (20) @(posedge clk);
		
		x0 <= 10'd1; y0 <= 9'd6; x1 <= 10'd1; y1 <= 9'd1; set <= 1; 		@(posedge clk) // Vertical Line, large to small in y
		set <= 0;								@(posedge clk)
		repeat (20) @(posedge clk);			
		
		x0 <= 10'd1; y0 <= 9'd1; x1 <= 10'd6; y1 <= 9'd3; set <= 1; 		@(posedge clk) // Line, not steep, left to right
		set <= 0;								@(posedge clk)
		repeat (20) @(posedge clk);
		
		x0 <= 10'd1; y0 <= 9'd1; x1 <= 10'd3; y1 <= 9'd6; set <= 1; 		@(posedge clk) // Line, steep, left to right
		set <= 0;								@(posedge clk)
		repeat (20) @(posedge clk);
		
		x0 <= 10'd6; y0 <= 9'd3; x1 <= 10'd1; y1 <= 9'd1; set <= 1; 		@(posedge clk) // Line, not steep, right to left
		set <= 0;								@(posedge clk)
		repeat (20) @(posedge clk);
		
		x0 <= 10'd3; y0 <= 9'd6; x1 <= 10'd1; y1 <= 9'd1; set <= 1; 		@(posedge clk) // Line, steep, right to left
		set <= 0;								@(posedge clk)
		repeat (20) @(posedge clk);
		
		x0 <= 10'd1; y0 <= 9'd1; x1 <= 10'd1; y1 <= 9'd1; set <= 1; 		@(posedge clk) // Same points.
		set <= 0;								@(posedge clk)
		repeat (20) @(posedge clk);
		$stop;
		
	end
endmodule
