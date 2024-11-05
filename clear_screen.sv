/*
	clear_screen erases the contents of the screen by writing 480 horizontal black lines,
	by sending outputs (10-bit) x0, x1, (9-bit) y0, y1 to the line_drawer module.
	This is done according to the state diagram proposed in Lab3.pdf.
	After asserting the 1-bit start input, we draw a black horizontal line between coords (0,0), (639, 0).
	Subsequent lines are drawn by incrementing the y coords until we reach (0, 479), (639, 479).
	
	1-bit output black governs which coordinates and 1-bit set values are accepted to the line_drawer module.
	When black = 1, clear_screen takes priority. When black = 0, sim_calculator takes priority.
	
	Parameter sim_timer governs how many cycles are required before incrementing the y values, 
	to give line_drawer enough time to process the previous inputs.
*/

module clear_screen (clk, reset, start, x0, x1, y0, y1, black, set);
	input logic clk, reset, start;
	output logic [9:0] x0, x1;
	output logic [8:0] y0, y1;
	output logic black, set;
	
	logic [31:0] timer;
	parameter sim_timer = 2000; // 2000 clock cycles are required to write a horizontal line.
	
	enum {s_idle, s_start, s_loop} ps, ns;
	
	always_comb begin
		case (ps)
			s_idle: if (start) ns = s_start;
					else ns = s_idle;
			s_start: ns = s_loop;
			s_loop: if (y0 < 480) ns = s_loop;
					else ns = s_idle;
		endcase
	end 
	
	always_ff @(posedge clk) begin
		if (reset) begin
			ps <= s_idle;
			x0 <= 10'bZ; y0 <= 9'bZ; x1 <= 10'bZ; y1 <= 9'bZ;
			timer <= 1;
			black <= 0;
			set <= 0;
		end 
		else begin
			ps <= ns;
			if (ps == s_idle) begin
				x0 <= 10'bZ; y0 <= 9'bZ; x1 <= 10'bZ; y1 <= 9'bZ;
				timer <= 1;
				black <= 0; // Priority is given to sim_calculator.
				set <= 0;
			end
			else
			if (ps == s_start) begin
				x0 <= 10'd0; y0 <= 9'd0; x1 <= 10'd639; y1 <= 9'b0;
				timer <= 1;
				black <= 1; // Black = 1 as we begin the screen clearing process to give priority to clear_screen.
				set <= 1;
			end
			else begin
				// Next output transition does not occur before timer = sim_timer.
				if (timer < sim_timer) begin
					timer <= timer + 1;
					set <= 0;
				end
				else begin
					y0 <= y0 + 1;
					y1 <= y1 + 1;
					timer <= 1; // Reset timer.
					set <= 1; // latch new inputs into line_drawer.
				end
			end
		end
	end
endmodule
					
		
		
// Testbench validates that the correct output sequence is transmitted after asserted start.
// set should be asserted as soon as values change, and we should return to s_idle after the animation.

module clear_screen_testbench();
	logic clk, reset, start;
	logic [9:0] x0, x1;
	logic [8:0] y0, y1;
	logic set, black;
	
	// Need a 2000 cycle delay to give enough time for each line to be properly drawn before we increment the outputs.
	clear_screen dut (.clk, .reset, .start, .x0, .x1, .y0, .y1, .set, .black);
	
	parameter clock_period = 20;
	initial begin
		clk <= 0;
		forever #(clock_period/2) clk <= ~clk;
	end
	
	initial begin
		reset <= 1;	start <= 0;		@(posedge clk)
		reset <= 0;	start <= 1;		@(posedge clk)
		start <= 0;				@(posedge clk)
		repeat (1000000) 			@(posedge clk); // Each line takes 2000 cycles, we have 480 lines to draw: need at least 960,000 cycles.
		$stop;
	end
endmodule
		
		
