/*Copyright 2011 Carlos Barreto	(carlobar@gmail.com)

 This file is part of FPGA_Monitor.

    FPGA_Monitor is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    FPGA_Monitor is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with FPGA_Monitor.  If not, see <http://www.gnu.org/licenses/>.
*/

module system(
	input clk_in,
	input reset_in,

	// LCD
	output e,
	output rs,
	output rw,
	inout [3:0] data_io,

	// switches
	input [3:0]	sw,
	input [1:0]	rot,

	// VGA
	output vga_hsync,
	output vga_vsync,
	output [2:0] rgb,

	// GPIO
	input [2:0] btn,    

	// leds
	output [3:0] led

);


assign e = 1'b0;
assign rs = 1'b0;
assign rw = 1'b0;
assign data_io = 4'b0;



wire up;

assign up = sw[3];



wire clkin;

`ifndef SIMULATION
	IBUFG clkin_BUFG (
      		.O(clkin), 	// Clock buffer output
      		.I(clk_in)  	// Clock buffer input (connect directly to
            			// top-level port)	
   	);
//defparam IBUFG_inst.IOSTANDARD = "LVCMOS25";
`else
	assign clkin = clk_in;
`endif


wire sys_rst;
assign sys_rst = reset_in;


parameter [2:0] zero = 0, one = 1, two = 2, three =3, four = 4, five = 5;
reg 	[2:0] state_counter;
reg 	[2:0] next_state_counter;

wire start_stop;
assign start_stop = sw[0];
assign led[3] = sw[0];

// vga controller signals
wire [10:0] x;
wire [9:0] y;

wire [9:0] state, buf_graph;

sampling  #(
	.data_size(7),	
	.state_size(10),
	.mem_width(7)
)sampling(
	.in_dcm(clkin),
	.sys_rst(sys_rst),
	.rst_in(rst1),

	.rot(rot),

	.start_stop(start_stop),

	// sampling signals
	.clk(clkin),
	.bit_0(state_counter[0]),
	.bit_1(state_counter[1]),
	.bit_2(state_counter[2]),
	.vector_a(state_counter),

	.state(state),
	.buf_graph(buf_graph),

	.x_in(x),
	.phase_counter(phase_counter)

);


vga_controller vga_cnt(
	.clk(clkin), 
	.rst(reset_in),
	.hsync(vga_hsync),
	.vsync(vga_vsync),
	.x(x),
	.y(y)
);

graph #(
	.samples(25),
	.data_width(10),
	.height(10)
) graph (
	.clk(clkin),
	.rst(reset_in),
	.x(x),
	.y(y),
	.state(state),
	.buf_data(buf_graph),
	.rgb_out(rgb)
);






assign led[2:0] = state_counter;



always @(posedge clkin) begin
	if(reset_in)	begin
		state_counter <= zero;
	end
	else	begin
		state_counter <= next_state_counter;
	end
end

always @(*) begin
	next_state_counter = state_counter;
	case(state_counter)
		zero: begin
			if (up) begin
				next_state_counter = one;
			end
			else begin
				next_state_counter = five;
			end
		end
			
		one: begin
			if (up) begin
				next_state_counter = two;
			end
			else begin
				next_state_counter = zero;
			end

		end

		two: begin
			if (up) begin
				next_state_counter = three;
			end
			else begin
				next_state_counter = one;
			end

		end

		three: begin
			if (up) begin
				next_state_counter = four;
			end
			else begin
				next_state_counter = two;
			end

		end

		four: begin
			if (up) begin
				next_state_counter = five;
			end
			else begin
				next_state_counter = three;
			end

		end

		five: begin
			if (up) begin
				next_state_counter = zero;
			end
			else begin
				next_state_counter = four;
			end

		end

		default: begin
			next_state_counter = zero;
		end
	endcase
end

endmodule


