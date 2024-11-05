/*
	sim_calculator drives the line animation by sending coordinates (10-bit) x0, x1, (9-bit) y0, y1 to the line_drawer module.
	These coordinates follow a pre-determined pattern outlined by the state diagram in Lab3.pdf.
	First, as the 1-bit start signal is asserted to begin the animation, a vertical line is drawn according 
	to coordinates (20, 20), (20, 460). 
	Subsequent lines are drawn when in states s0 to s3 by shifting the x coordinates to and from 20 and 620 in a staggered manner.
	State changes and coordinate transmission to line_drawer is accomplished in respect to a clock-divider governed by timer.
	Each coordinate change must be accompanied by an assertion of 1-bit set, which signals line_drawer to latch the contents of x0, x1, y0, y1.
	
	Parameter sim_timer governs how many cycles are required before incrementing an x value. For simulation purposes, this is set to 2000.
*/


module sim_calculator #(sim_timer=50000000) (clk, reset, start, x0, x1, y0, y1, set);
	input logic clk, reset, start;
	output logic [9:0] x0, x1;
	output logic [8:0] y0, y1;
	output logic set;
	
	// Timer needs to be equal to sim_timer before incrementing an x value.
	logic [31:0] timer;
	
	// State registers
	enum {s_idle, s_start, s0, s1, s2, s3} ps, ns;
	
	// Next state behaviour (see state diagram in Lab3.pdf)
	always_comb begin
		case (ps)
			s_idle: if (start) ns = s_start;
				else ns = s_idle;
			s_start: ns = s0;
			s0: if (x1 == 620) ns = s1;
				else ns = s0;
			s1: if (x0 == 620) ns = s2;
				else ns = s1;
			s2: if (x1 == 20) ns = s3;
				else ns = s2;
			s3: if (x0 == 20) ns = s_idle;
				else ns = s3;
		endcase
	end
	
	// State and output transitions 
	always_ff @(posedge clk) begin
		if (reset) begin
			ps <= s_idle;
			x0 <= 10'bZ; y0 <= 9'bZ; x1 <= 10'bZ; y1 <= 9'bZ;
			timer <= 1;
		end
		else begin
			// State transition
			ps <= ns;
			
			if (ps == s_idle) begin
				x0 <= 10'bZ; y0 <= 9'bZ; x1 <= 10'bZ; y1 <= 9'bZ;
				timer <= 1;
				set <= 0;
			end
			else
			if (ps == s_start) begin
				// Initial values
				set <= 1;
				timer <= 1;
				x0 <= 10'd20; y0 <= 9'd20; x1 <= 10'd20; y1 <= 9'd460;
			end
			else begin
				// Next output transition does not occur before timer = sim_timer.
				if (timer < sim_timer) begin
					timer <= timer + 1;
					set <= 0;
				end
				else begin
					// Output Transitions.
					timer <= 1;
					set <= 1;
					if (ps == s0 && x1 < 10'd620) x1 <= x1 + 10'd120;
					if (ps == s1 && x0 < 10'd620) x0 <= x0 + 10'd120;
					if (ps == s2 && x1 > 10'd20) x1 <= x1 - 10'd120;
					if (ps == s3 && x0 > 10'd20) x0 <= x0 - 10'd120;
				end
			end
		end
	end
endmodule



// Testbench validates that the correct output sequence is transmitted after asserted start.
// set should be asserted as soon as values change, and we should return to s_idle after the animation.

module sim_calculator_testbench();
	logic clk, reset, start;
	logic [9:0] x0, x1;
	logic [8:0] y0, y1;
	logic set;
	
	// Need a 2000 cycle delay to give enough time for each line to be properly drawn before we increment the outputs.
	sim_calculator #(2000) dut (.clk, .reset, .start, .x0, .x1, .y0, .y1, .set);
	
	parameter clock_period = 20;
	initial begin
		clk <= 0;
		forever #(clock_period/2) clk <= ~clk;
	end
	
	initial begin
		reset <= 1;	start <= 0;		@(posedge clk)
		reset <= 0;	start <= 1;		@(posedge clk)
		start <= 0;				@(posedge clk)
		repeat (50000) 				@(posedge clk); // Each line takes 2000 cycles, we have 20 different coordinates => need at least 40000 cycles
		$stop;
	end
endmodule
	
	
	
