/*
	input_selector manages the algorithm reduction process,
	by using the 10-bit and 9-bit x0, x1, y0, y1 inputs and 'choosing' the correct 10-bit inputs to 
	coordinate_generator, start_h, end_h, start_v, end_v. input_selector also asserts whether the inputted
	line is steep.
*/

module input_selector (
		input logic [9:0] x0, x1, 
		input logic [8:0] y0, y1,
		output logic [9:0] start_h, end_h, start_v, end_v,
		output logic is_steep
		);
	logic [9:0] abs_x; 
	logic [8:0] abs_y;
	logic [9:0] temp_sh, temp_eh, temp_sv, temp_ev;
	
	// instances of abs to calculate the 'distance' between x values and y values.
	// The results, abs_x and abs_y will be used to determine whether the line is steep.
	abs #(10) x_distance (.val_1(x1), .val_2(x0), .out(abs_x));
	abs #(9) y_distance (.val_1(y1), .val_2(y0), .out(abs_y));
	
	// is_steep governs the first swap process, and is sent to coordinate_generator.
	assign is_steep = abs_y > abs_x;
	
	// This process is synonymous to the 'swap' operations described in the pseudo-code.
	always_comb begin
		if (is_steep) begin
			temp_sh = y0;
			temp_eh = y1;
			temp_sv = x0;
			temp_ev = x1;
		end
		else begin
			temp_sh = x0;
			temp_eh = x1;
			temp_sv = y0;
			temp_ev = y1;
		end
		if (temp_sh > temp_eh) begin
			start_h = temp_eh;
			end_h = temp_sh;
			start_v = temp_ev;
			end_v = temp_sv;
		end
		else begin
			start_h = temp_sh;
			end_h = temp_eh;
			start_v = temp_sv;
			end_v = temp_ev;
		end
	end // always
endmodule	


// This testbench was designed to assess each of the 9 possible cases outlined in Lab3.pdf.

module input_selector_testbench();
	logic [9:0] x0, x1;
	logic [8:0] y0, y1;
	logic [9:0] start_h, end_h, start_v, end_v;
	logic is_steep;
	
	input_selector dut (.x0, .x1, .y0, .y1, .start_h, .end_h, .start_v, .end_v, .is_steep);
	
	initial begin
		x0 = 10'd1; y0 = 9'd1; x1 = 10'd12; y1 = 9'd5; #50; // Case 1: Not steep, left to right.
		x0 = 10'd1; y0 = 9'd1; x1 = 10'd5; y1 = 9'd12; #50; // Case 2: Steep, left to right.
		x0 = 10'd12; y0 = 9'd5; x1 = 10'd1; y1 = 9'd1; #50; // Case 3: Not steep, right to left.
		x0 = 10'd5; y0 = 9'd12; x1 = 10'd1; y1 = 9'd1; #50; // Case 4: Steep, right to left.
		x0 = 10'd1; y0 = 9'd1; x1 = 10'd10; y1 = 9'd1; #50; // Case 5: Horizontal, left to right.
		x0 = 10'd10; y0 = 9'd1; x1 = 10'd1; y1 = 9'd1; #50; // Case 6: Horizontal, right to left.
		x0 = 10'd1; y0 = 9'd1; x1 = 10'd1; y1 = 9'd10; #50; // Case 7: Vertical, smaller to larger y.
		x0 = 10'd1; y0 = 9'd10; x1 = 10'd1; y1 = 9'd1; #50; // Case 8: Vertical, larger to smaller y.
		x0 = 10'd1; y0 = 9'd3; x1 = 10'd1; y1 = 9'd3;  #50; // Case 9: (x0, y0) = (x1, y1)
	end //initial
	
endmodule
		
		
