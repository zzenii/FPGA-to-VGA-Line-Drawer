/*
	coordinate_generator_controller is the control unit of the coordinate_generator module
 	(see block diagrams). It receives external inputs set and reset, to inform the datapath
	to latch or clear the contents of x0, x1, y0, y1, is_steep into the internal registers of the module.
	The remaining inputs and outputs are status signals thoroughly described in Lab3.pdf.
*/


module coordinate_generator_controller (
				input logic clk, reset, 
				input logic set, steep, loop_condition, err_gtz,
				output logic idle_default, set_regs, incr_loop, swap, no_swap, new_line, no_new_line
				);
	
	// ps and ns are used for state register updating/transmitting
	// See ASMD chart in Lab3.pdf.
	enum {s_idle, s_loop, s_write, s_incr_y} ps, ns;
	
	// Next state behaviour (See ASMD chart in Lab3.pdf)
	always_comb begin
		case (ps)
			s_idle:	if (set) ns = s_loop;
						else ns = s_idle;
			s_loop:	if (loop_condition) ns = s_write;
						else ns = s_idle;
			s_write:	ns = s_incr_y;
			s_incr_y: ns = s_loop;
		endcase
	end
	
	// Asserting control signals according to ASMD chart.
	assign idle_default = (ps == s_idle) && !set;
	assign set_regs = (ps == s_idle) && set;
	assign incr_loop = (ps == s_loop) && loop_condition;
	assign swap = (ps == s_write) && steep;
	assign no_swap = (ps == s_write) && !steep;
	assign new_line = (ps == s_incr_y) && err_gtz;
	assign no_new_line = (ps == s_incr_y) && !err_gtz;
	
	// State transitions.
	always_ff @(posedge clk) begin
		if (reset)
			ps <= s_idle;
		else
			ps <= ns;
	end
endmodule
