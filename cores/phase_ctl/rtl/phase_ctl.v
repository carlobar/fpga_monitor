/*
    Copyright 2011 Carlos Barreto	

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

module phase_ctl (
	input clk,
	input rst,
	input [1:0] rot,
	input locked,
	output reg psen,
	output reg psincdec,
	input psdone,
	output psclk,
	output reg [31:0] counter

);

wire event_, right_;
assign psclk = clk;

rot_button rot_button(
	.clk(clk),
	.rst(rst),
	.rot(rot),
	.event_(event_),
	.right_(right_)
);

reg inc_dec;

always @(posedge clk) begin
	if(rst) 
		inc_dec <= 1'b0;
	else if(event_)
		inc_dec <= right_;
	else 
		inc_dec <= inc_dec;
end


parameter [1:0] idle_ = 0, send_ = 1, wait_ = 2;
reg [1:0] state, next_state;

always @(posedge clk) begin
	if(rst)
		state = idle_;
	else
		state = next_state;
end


always @(*) begin
	next_state = state;
	case(state)
		idle_: begin
			if (event_ & locked)
				next_state = send_;
			else
				next_state = state;
		end
		send_: begin 
			next_state = wait_;
		end
		wait_: begin
			if (psdone)
				next_state = idle_;
			else
				next_state = wait_;
		end
	endcase
end

always @(*) begin
	case(state)
		idle_: begin
			psen = 1'b0;
			psincdec = 1'b0;
		end
		send_: begin
			psen = 1'b1;
			psincdec = inc_dec;
		end
		wait_: begin
			psen = 1'b0;
			psincdec = 1'b0;

		end
		default: begin
			psen = 1'b0;
			psincdec = 1'b0;
		end
	endcase
end



always @(posedge clk) begin
	if (rst)
		counter <= 32'd500;
	else if ((counter < 32'd755) & inc_dec & psdone)
		counter <= counter+1;
	else if ((counter > 32'd245) & ~inc_dec & psdone)
		counter <= counter-1;
	else
		counter <= counter;
end



endmodule
