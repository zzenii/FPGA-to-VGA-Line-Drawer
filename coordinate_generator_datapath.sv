/*
	coordinate_generator_datapath is the datapath component of the coordinate_generator module
 	(see block diagrams). It receives and outputs all data-related signals, namely
	10-bit inputs x0, x1, y0, y1 (start and end coords), and 10/9-bit outputs x and y, respectively.
	Furthermore, it receives numerous 1-bit control signals and outputs three 1-bit status signals,
	described in the provided block diagrams.
*/


module coordinate_generator_datapath (
			input logic clk, reset, is_steep,
			input logic set_regs, incr_loop, swap, no_swap, new_line, no_new_line, idle_default,
			input logic [9:0] x0, x1, y0, y1,
			output logic [9:0] x,
			output logic [8:0] y,
			output logic loop_condition, err_gtz, steep
			);
	
	// Internal registers holding relevant calculation data (seen in pseudo-code)
	integer delta_x, delta_y, error, y_step, i;
	
	// Given that we need to swap the x and y coordinates if the line is steep, we need buffer variables
	// x_buff and y_buff.
	logic [9:0] x_buff, y_buff, abs_y;
	
	// Instance of abs to calculate the 'distance' between the y values, necessary for delta_y.
	abs #(10) distance_y (.val_1(y0), .val_2(y1), .out(abs_y));
	
	// RTL operations according to each possible control signal. See ASMD chart in Lab3.pdf for more information.
	always_ff @(posedge clk) begin
		if (reset) begin
			delta_x <= 0; delta_y <= 0; error <= 0; y_step <= 0; x_buff <= 0; y_buff <= 0;
			steep <= 0;
			x <= 10'bX;
			y <= 9'bX;
		end
		else begin
			if (idle_default) begin
				x <= 10'bX;
				y <= 9'bX;
				i <= 0;
			end
			if (set_regs) begin
				x_buff <= x0;
				y_buff <= y0;
				y_step <= (y1 > y0) ? 1 : -1;
				delta_x <= x1 - x0;
				delta_y <= abs_y;
				error <= -((x1 - x0)/2);
				steep <= is_steep;
			end
			if (incr_loop) begin
				i <= i + 1;
				error <= error + delta_y;
			end
			if (swap) begin
				x <= y_buff;
				y <= x_buff;
			end
			if (no_swap) begin
				x <= x_buff;
				y <= y_buff;
			end
			if (new_line) begin
				x_buff <= x_buff + 1;
				y_buff <= y_buff + y_step;
				error <= error - delta_x;
			end
			if (no_new_line)
				x_buff <= x_buff + 1;
		end	
	end
	
	// Output status signals back to control unit.
	assign loop_condition = (i <= delta_x);
	assign err_gtz = (error >= 0);

endmodule 
